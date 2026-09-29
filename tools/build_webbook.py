#!/usr/bin/env python3
"""Build the Verilog tutorial into a searchable bilingual static webbook.

The page wrappers under drafts/book (Korean) and drafts/book/en (English) contain
stable metadata. Each wrapper maps to one canonical tutorial README (under tutorial/
or tutorial_en/) so the repository and website share one body of instructional content.
The builder uses only the Python standard library.
"""

from __future__ import annotations

import argparse
import html
import json
import os
import re
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable
from urllib.parse import quote, unquote


ROOT = Path(__file__).resolve().parents[1]
BOOK_DIR = ROOT / "drafts" / "book"
EN_BOOK_DIR = BOOK_DIR / "en"
TOC_PATH = BOOK_DIR / "toc.yml"
EN_TOC_PATH = EN_BOOK_DIR / "toc.yml"
STYLE_PATH = ROOT / "styles" / "webbook.css"
SCRIPT_PATH = ROOT / "styles" / "webbook.js"
FAVICON_PATH = ROOT / "styles" / "favicon.svg"
PUBLISH_DIR = ROOT / "publish" / "webbook"
TUTORIAL_DIR = ROOT / "tutorial"
TUTORIAL_EN_DIR = ROOT / "tutorial_en"

REQUIRED_FIELDS = {
    "canonical_id",
    "id",
    "aliases",
    "title",
    "chapter",
    "type",
    "status",
    "topic",
    "summary",
    "output",
    "created",
    "updated",
    "related",
    "source_file",
}

I18N: dict[str, dict[str, str]] = {
    "ko": {
        "lang_code": "ko",
        "lang_name": "한국어",
        "alt_lang_code": "en",
        "alt_lang_name": "English",
        "lang_switch_label": "언어 선택 / Language",
        "menu": "목차",
        "search_label": "웹북 검색",
        "search_placeholder": "예: always, FSM, VCD",
        "search_empty": "검색 결과가 없습니다.",
        "search_ready": "검색 색인 준비 중",
        "copy": "복사",
        "copied": "복사됨",
        "section_toc": "이 페이지에서",
        "section_link": "이 절 링크",
        "prev": "이전 장",
        "next": "다음 장",
        "exec_flow": "실행 흐름",
        "interpret": "결과 해석",
        "source_view": "원본 보기",
        "source_edit": "GitHub에서 편집 제안",
        "source_prefix": "본문 원본: ",
        "repo_link": "GitHub 저장소",
    },
    "en": {
        "lang_code": "en",
        "lang_name": "English",
        "alt_lang_code": "ko",
        "alt_lang_name": "한국어",
        "lang_switch_label": "Language / 언어 선택",
        "menu": "Contents",
        "search_label": "Search Webbook",
        "search_placeholder": "e.g., always, FSM, VCD",
        "search_empty": "No results found.",
        "search_ready": "Loading search index",
        "copy": "Copy",
        "copied": "Copied",
        "section_toc": "On this page",
        "section_link": "Link to section",
        "prev": "Previous",
        "next": "Next",
        "exec_flow": "Execution Flow",
        "interpret": "Interpret Results",
        "source_view": "View Source",
        "source_edit": "Suggest edits on GitHub",
        "source_prefix": "Source: ",
        "repo_link": "GitHub Repository",
    },
}


@dataclass(frozen=True)
class Heading:
    level: int
    title: str
    anchor: str


@dataclass
class Page:
    id: str
    title: str
    wrapper_source: Path
    content_source: Path
    slug: str
    chapter: str
    summary: str
    metadata: dict[str, Any]
    body: str
    lang: str = "ko"

    @property
    def base_publish_dir(self) -> Path:
        return PUBLISH_DIR / "en" if self.lang == "en" else PUBLISH_DIR

    @property
    def output_dir(self) -> Path:
        return self.base_publish_dir / self.slug if self.slug else self.base_publish_dir

    @property
    def output_path(self) -> Path:
        return self.output_dir / "index.html"

    @property
    def site_path(self) -> str:
        prefix = "en/" if self.lang == "en" else ""
        return f"{prefix}{self.slug}/" if self.slug else prefix


def is_within(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def read_toc(path: Path) -> dict[str, Any]:
    try:
        toc = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise SystemExit(f"목차 파일을 읽을 수 없습니다: {path} ({exc})") from exc
    if "book" not in toc or "chapters" not in toc:
        raise SystemExit(f"{path}에 book과 chapters가 필요합니다.")
    return toc


def flatten_toc(toc: dict[str, Any]) -> list[dict[str, str]]:
    items: list[dict[str, str]] = []
    for chapter in toc["chapters"]:
        items.append(
            {
                "id": chapter["id"],
                "title": chapter["title"],
                "file": chapter["file"],
                "slug": chapter["slug"],
                "chapter": chapter["title"],
            }
        )
        for page in chapter.get("pages", []):
            items.append(
                {
                    "id": page["id"],
                    "title": page["title"],
                    "file": page["file"],
                    "slug": page["slug"],
                    "chapter": chapter["title"],
                }
            )
    return items


def parse_frontmatter(text: str) -> tuple[dict[str, Any], str]:
    if not text.startswith("---\n"):
        return {}, text
    parts = text.split("---", 2)
    if len(parts) != 3:
        return {}, text
    raw_meta, body = parts[1], parts[2]
    metadata: dict[str, Any] = {}
    current_key: str | None = None
    for raw_line in raw_meta.splitlines():
        line = raw_line.rstrip()
        if not line:
            continue
        if line.startswith("  - ") and current_key:
            metadata.setdefault(current_key, []).append(line[4:].strip().strip('"'))
            continue
        if ":" in line:
            key, value = line.split(":", 1)
            key = key.strip()
            value = value.strip().strip('"')
            if value:
                metadata[key] = value
                current_key = None
            else:
                metadata[key] = []
                current_key = key
    return metadata, body.lstrip("\n")


def load_pages(
    book_dir: Path,
    toc: dict[str, Any],
    content_parent: Path,
    lang: str = "ko",
) -> list[Page]:
    pages: list[Page] = []
    seen_ids: set[str] = set()
    seen_aliases: set[str] = set()
    seen_sources: set[Path] = set()
    toc_items = flatten_toc(toc)

    for item in toc_items:
        wrapper_source = (book_dir / item["file"]).resolve()
        if not is_within(wrapper_source, book_dir):
            raise SystemExit(f"목차 경로가 {book_dir} 범위를 벗어났습니다: {item['file']}")
        if not wrapper_source.is_file():
            raise SystemExit(f"목차에 등록된 페이지가 없습니다: {wrapper_source}")

        metadata, wrapper_body = parse_frontmatter(wrapper_source.read_text(encoding="utf-8"))
        missing = REQUIRED_FIELDS - metadata.keys()
        if missing:
            fields = ", ".join(sorted(missing))
            raise SystemExit(f"{wrapper_source} frontmatter 필드가 필요합니다: {fields}")
        if wrapper_body.strip():
            raise SystemExit(f"메타데이터 페이지 본문은 비워 둡니다: {wrapper_source}")

        page_id = str(metadata["id"])
        if page_id != item["id"]:
            raise SystemExit(f"toc id와 frontmatter id가 다릅니다: {item['id']} / {page_id}")
        if page_id in seen_ids:
            raise SystemExit(f"중복 페이지 id: {page_id}")
        seen_ids.add(page_id)

        aliases = metadata.get("aliases", [])
        aliases = [aliases] if isinstance(aliases, str) else aliases
        for alias in aliases:
            if alias in seen_aliases or alias in seen_ids:
                raise SystemExit(f"별칭이 충돌합니다: {wrapper_source} / {alias}")
            seen_aliases.add(alias)

        content_source = (ROOT / str(metadata["source_file"])).resolve()
        if not is_within(content_source, content_parent):
            raise SystemExit(f"웹북 본문은 {content_parent} 범위에서 읽습니다: {content_source}")
        if not content_source.is_file():
            raise SystemExit(f"웹북 본문 파일이 없습니다: {content_source}")
        if content_source in seen_sources:
            raise SystemExit(f"웹북 본문이 중복 연결되었습니다: {content_source}")
        seen_sources.add(content_source)

        pages.append(
            Page(
                id=page_id,
                title=str(metadata.get("title", item["title"])),
                wrapper_source=wrapper_source,
                content_source=content_source,
                slug=item["slug"].strip("/"),
                chapter=str(metadata.get("chapter", item["chapter"])),
                summary=str(metadata.get("summary", "")),
                metadata=metadata,
                body=content_source.read_text(encoding="utf-8"),
                lang=lang,
            )
        )

    known_wrappers = {(book_dir / item["file"]).resolve() for item in toc_items}
    extra_wrappers = sorted(
        path
        for path in book_dir.rglob("*.md")
        if path.resolve() not in known_wrappers and (lang != "ko" or "en" not in path.parts)
    )
    if extra_wrappers:
        names = ", ".join(path.relative_to(ROOT).as_posix() for path in extra_wrappers)
        raise SystemExit(f"{book_dir}에 등록할 Markdown 페이지가 있습니다: {names}")
    return pages


def slugify_heading(text: str) -> str:
    plain = re.sub(r"`([^`]+)`", r"\1", text)
    plain = re.sub(r"<[^>]+>", "", plain)
    plain = re.sub(r"[^\w가-힣\- ]+", "", plain).strip().lower()
    return re.sub(r"\s+", "-", plain) or "section"


def split_table_row(line: str) -> list[str]:
    row = line.strip()
    if row.startswith("|"):
        row = row[1:]
    if row.endswith("|"):
        row = row[:-1]
    cells: list[str] = []
    current: list[str] = []
    in_code = False
    escaped = False
    for char in row:
        if escaped:
            current.append(char)
            escaped = False
            continue
        if char == "\\":
            current.append(char)
            escaped = True
            continue
        if char == "`":
            in_code = not in_code
            current.append(char)
            continue
        if char == "|" and not in_code:
            cells.append("".join(current).strip())
            current = []
            continue
        current.append(char)
    cells.append("".join(current).strip())
    return cells


def is_table_separator(line: str) -> bool:
    cells = split_table_row(line)
    return bool(cells) and all(re.fullmatch(r":?-{3,}:?", cell.replace(" ", "")) for cell in cells)


def inline_markdown(text: str, rewrite_href: Callable[[str], str]) -> str:
    code_tokens: list[str] = []
    link_tokens: list[str] = []

    def protect_code(match: re.Match[str]) -> str:
        token = f"@@WB_CODE_{len(code_tokens)}@@"
        code_tokens.append(f"<code>{html.escape(match.group(1))}</code>")
        return token

    protected = re.sub(r"`([^`]+)`", protect_code, text)

    def protect_link(match: re.Match[str]) -> str:
        token = f"@@WB_LINK_{len(link_tokens)}@@"
        label = html.escape(match.group(1))
        href = html.escape(rewrite_href(match.group(2)), quote=True)
        external = ' target="_blank" rel="noopener"' if href.startswith(("http://", "https://")) else ""
        link_tokens.append(f'<a href="{href}"{external}>{label}</a>')
        return token

    protected = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", protect_link, protected)
    rendered = html.escape(protected)
    rendered = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", rendered)
    rendered = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"<em>\1</em>", rendered)
    for index, value in enumerate(link_tokens):
        rendered = rendered.replace(f"@@WB_LINK_{index}@@", value)
    for index, value in enumerate(code_tokens):
        rendered = rendered.replace(f"@@WB_CODE_{index}@@", value)
    return rendered


def markdown_to_html(
    markdown: str,
    rewrite_href: Callable[[str], str],
    lang: str = "ko",
) -> tuple[str, list[Heading]]:
    lines = markdown.splitlines()
    out: list[str] = []
    headings: list[Heading] = []
    heading_counts: dict[str, int] = {}
    index = 0
    in_ul = False
    in_ol = False
    in_code = False
    code_language = "text"
    code_lines: list[str] = []
    copy_label = I18N[lang]["copy"]

    def close_lists() -> None:
        nonlocal in_ul, in_ol
        if in_ul:
            out.append("</ul>")
            in_ul = False
        if in_ol:
            out.append("</ol>")
            in_ol = False

    def starts_block(line: str, next_line: str = "") -> bool:
        stripped = line.strip()
        return bool(
            not stripped
            or stripped.startswith("```")
            or re.match(r"^#{1,6}\s+", stripped)
            or stripped in {"---", "***", "___"}
            or stripped.startswith(("- ", "* ", "> "))
            or re.match(r"^\d+\.\s+", stripped)
            or (stripped.startswith("|") and is_table_separator(next_line.strip()))
        )

    while index < len(lines):
        line = lines[index]
        stripped = line.strip()

        if stripped.startswith("```"):
            if in_code:
                code_html = html.escape("\n".join(code_lines))
                language = html.escape(code_language or "text")
                out.append(
                    '<div class="code-shell">'
                    f'<button class="copy-code" type="button">{html.escape(copy_label)}</button>'
                    f'<pre><code class="language-{language}">{code_html}</code></pre>'
                    "</div>"
                )
                in_code = False
                code_lines = []
            else:
                close_lists()
                in_code = True
                code_language = stripped[3:].strip() or "text"
            index += 1
            continue

        if in_code:
            code_lines.append(line)
            index += 1
            continue

        if not stripped:
            close_lists()
            index += 1
            continue

        if stripped in {"---", "***", "___"}:
            close_lists()
            out.append("<hr>")
            index += 1
            continue

        if stripped.startswith("|") and index + 1 < len(lines) and is_table_separator(lines[index + 1].strip()):
            close_lists()
            table_lines = [stripped]
            index += 2
            while index < len(lines) and lines[index].strip().startswith("|"):
                table_lines.append(lines[index].strip())
                index += 1
            header = split_table_row(table_lines[0])
            rows = [split_table_row(row) for row in table_lines[1:]]
            out.append('<div class="table-scroll"><table><thead><tr>')
            out.extend(f"<th>{inline_markdown(cell, rewrite_href)}</th>" for cell in header)
            out.append("</tr></thead><tbody>")
            for row in rows:
                normalized = row + [""] * max(0, len(header) - len(row))
                out.append("<tr>")
                out.extend(f"<td>{inline_markdown(cell, rewrite_href)}</td>" for cell in normalized[: len(header)])
                out.append("</tr>")
            out.append("</tbody></table></div>")
            continue

        heading_match = re.match(r"^(#{1,6})\s+(.+)$", stripped)
        if heading_match:
            close_lists()
            level = len(heading_match.group(1))
            title = heading_match.group(2).strip()
            base_anchor = slugify_heading(title)
            count = heading_counts.get(base_anchor, 0) + 1
            heading_counts[base_anchor] = count
            anchor = base_anchor if count == 1 else f"{base_anchor}-{count}"
            headings.append(Heading(level=level, title=re.sub(r"`", "", title), anchor=anchor))
            out.append(
                f'<h{level} id="{html.escape(anchor)}">'
                f'{inline_markdown(title, rewrite_href)}'
                f'<a class="heading-anchor" href="#{html.escape(anchor)}" aria-label="{html.escape(I18N[lang]["section_link"])}">#</a>'
                f"</h{level}>"
            )
            index += 1
            continue

        if stripped.startswith("> "):
            close_lists()
            quote_lines: list[str] = []
            while index < len(lines) and lines[index].strip().startswith(">"):
                quote_lines.append(lines[index].strip().lstrip(">").strip())
                index += 1
            content = " ".join(quote_lines)
            out.append(f"<blockquote>{inline_markdown(content, rewrite_href)}</blockquote>")
            continue

        checkbox_match = re.match(r"^[-*]\s+\[([ xX])\]\s+(.+)$", stripped)
        if checkbox_match:
            if not in_ul:
                close_lists()
                out.append('<ul class="checklist">')
                in_ul = True
            checked = " checked" if checkbox_match.group(1).lower() == "x" else ""
            out.append(
                f'<li><input type="checkbox" disabled{checked}> '
                f'{inline_markdown(checkbox_match.group(2), rewrite_href)}</li>'
            )
            index += 1
            continue

        unordered_match = re.match(r"^[-*]\s+(.+)$", stripped)
        if unordered_match:
            if not in_ul:
                close_lists()
                out.append("<ul>")
                in_ul = True
            out.append(f"<li>{inline_markdown(unordered_match.group(1), rewrite_href)}</li>")
            index += 1
            continue

        ordered_match = re.match(r"^\d+\.\s+(.+)$", stripped)
        if ordered_match:
            if not in_ol:
                close_lists()
                out.append("<ol>")
                in_ol = True
            out.append(f"<li>{inline_markdown(ordered_match.group(1), rewrite_href)}</li>")
            index += 1
            continue

        close_lists()
        paragraph = [stripped]
        index += 1
        while index < len(lines):
            next_line = lines[index]
            after_next = lines[index + 1] if index + 1 < len(lines) else ""
            if starts_block(next_line, after_next):
                break
            paragraph.append(next_line.strip())
            index += 1
        out.append(f"<p>{inline_markdown(' '.join(paragraph), rewrite_href)}</p>")

    if in_code:
        raise SystemExit("닫는 ```가 필요한 코드 블록이 있습니다.")
    close_lists()
    return "\n".join(out), headings


def relative_link(from_page: Page, to_page: Page) -> str:
    value = os.path.relpath(to_page.output_path, from_page.output_dir)
    return value.replace(os.sep, "/")


def source_url(toc: dict[str, Any], source: Path) -> str:
    repository = str(toc["book"]["repository_url"]).rstrip("/")
    relative = source.relative_to(ROOT).as_posix()
    return f"{repository}/blob/main/{quote(relative, safe='/')}"


def make_link_rewriter(
    toc: dict[str, Any],
    current: Page,
    page_by_content: dict[Path, Page],
) -> Callable[[str], str]:
    def rewrite(href: str) -> str:
        if href.startswith(("http://", "https://", "mailto:", "#")):
            return href
        path_part, separator, fragment = href.partition("#")
        target = (current.content_source.parent / unquote(path_part)).resolve()
        if target in page_by_content:
            page_href = relative_link(current, page_by_content[target])
            return f"{page_href}#{fragment}" if separator else page_href
        if target.is_file() and is_within(target, ROOT):
            return source_url(toc, target) + (f"#{fragment}" if separator else "")
        return href

    return rewrite


def render_lang_switch(from_page: Page, alt_page: Page | None, lang: str) -> str:
    labels = I18N[lang]
    if lang == "ko":
        ko_href = "./" if from_page.slug == "" else f"../{from_page.slug}/"
        en_target = alt_page.output_path if alt_page else (PUBLISH_DIR / "en" / from_page.slug / "index.html")
        en_href = os.path.relpath(en_target, from_page.output_dir).replace(os.sep, "/")
        active_ko = " active"
        active_en = ""
    else:
        ko_target = alt_page.output_path if alt_page else (PUBLISH_DIR / from_page.slug / "index.html")
        ko_href = os.path.relpath(ko_target, from_page.output_dir).replace(os.sep, "/")
        en_href = "./" if from_page.slug == "" else f"../{from_page.slug}/"
        active_ko = ""
        active_en = " active"

    return (
        f'<div class="lang-switch" role="group" aria-label="{html.escape(labels["lang_switch_label"])}">'
        f'<a href="{html.escape(ko_href)}" class="lang-btn{active_ko}" data-lang="ko" title="한국어로 보기">KO</a>'
        '<span class="lang-sep">/</span>'
        f'<a href="{html.escape(en_href)}" class="lang-btn{active_en}" data-lang="en" title="View in English">EN</a>'
        '</div>'
    )


def render_sidebar(
    toc: dict[str, Any],
    current: Page,
    page_by_wrapper: dict[str, Page],
    lang: str,
    alt_page: Page | None,
) -> str:
    labels = I18N[lang]
    home = page_by_wrapper["index.md"]
    parts = [
        f'<a class="book-title" href="{relative_link(current, home)}">{html.escape(toc["book"]["title"])}</a>',
        f'<p class="book-subtitle">{html.escape(toc["book"].get("subtitle", ""))}</p>',
        f'<div class="sidebar-lang-container">{render_lang_switch(current, alt_page, lang)}</div>',
        '<div class="search-box">',
        f'<label for="book-search">{html.escape(labels["search_label"])}</label>',
        f'<input id="book-search" type="search" placeholder="{html.escape(labels["search_placeholder"])}" autocomplete="off">',
        '<div id="search-results" class="search-results" aria-live="polite"></div>',
        '</div>',
        f'<nav class="toc" aria-label="{html.escape(labels["menu"])}">',
    ]
    for chapter in toc["chapters"]:
        page = page_by_wrapper[chapter["file"]]
        active = " active" if page.id == current.id else ""
        current_attr = ' aria-current="page"' if active else ""
        parts.append(
            f'<a class="toc-link{active}" href="{relative_link(current, page)}"{current_attr}>'
            f'{html.escape(chapter["title"])}</a>'
        )
    parts.extend(
        [
            '</nav>',
            '<div class="sidebar-meta">',
            f'<a href="{html.escape(toc["book"]["repository_url"])}" target="_blank" rel="noopener">{html.escape(labels["repo_link"])}</a>',
            '</div>',
        ]
    )
    return "\n".join(parts)


def render_section_toc(headings: list[Heading], lang: str) -> str:
    items = [heading for heading in headings if heading.level in {2, 3}]
    if not items:
        return ""
    links = [
        f'<a class="level-{heading.level}" href="#{html.escape(heading.anchor)}">{html.escape(heading.title)}</a>'
        for heading in items
    ]
    title_text = html.escape(I18N[lang]["section_toc"])
    return f'<nav class="section-toc" aria-label="{title_text}"><strong>{title_text}</strong>{"".join(links)}</nav>'


def render_page(
    toc: dict[str, Any],
    pages: list[Page],
    index: int,
    page_by_wrapper: dict[str, Page],
    page_by_content: dict[Path, Page],
    lang: str,
    alt_page: Page | None,
) -> str:
    page = pages[index]
    labels = I18N[lang]
    previous = pages[index - 1] if index > 0 else None
    following = pages[index + 1] if index + 1 < len(pages) else None
    rewrite_href = make_link_rewriter(toc, page, page_by_content)
    content, headings = markdown_to_html(page.body, rewrite_href, lang)
    style_href = os.path.relpath(PUBLISH_DIR / "webbook.css", page.output_dir).replace(os.sep, "/")
    script_href = os.path.relpath(PUBLISH_DIR / "webbook.js", page.output_dir).replace(os.sep, "/")
    favicon_href = os.path.relpath(PUBLISH_DIR / "favicon.svg", page.output_dir).replace(os.sep, "/")

    search_file = "en/search-index.json" if lang == "en" else "search-index.json"
    search_href = os.path.relpath(PUBLISH_DIR / search_file, page.output_dir).replace(os.sep, "/")

    site_root_dir = PUBLISH_DIR / "en" if lang == "en" else PUBLISH_DIR
    site_root = os.path.relpath(site_root_dir, page.output_dir).replace(os.sep, "/")
    site_root = "./" if site_root == "." else f"{site_root}/"

    base_site_url = str(toc["book"]["site_url"]).rstrip("/")
    if lang == "en" and not base_site_url.endswith("/en"):
        canonical = f"{base_site_url}/en/{page.slug}/" if page.slug else f"{base_site_url}/en/"
    else:
        canonical = f"{base_site_url}/{page.slug}/" if page.slug else f"{base_site_url}/"

    # Alternate link for hreflang
    if alt_page:
        if lang == "ko":
            alt_canonical = f"{base_site_url}/en/{alt_page.slug}/" if alt_page.slug else f"{base_site_url}/en/"
            alt_lang = "en"
        else:
            alt_canonical = f"{base_site_url}/{alt_page.slug}/" if alt_page.slug else f"{base_site_url}/"
            alt_lang = "ko"
        alternate_tag = f'<link rel="alternate" hreflang="{alt_lang}" href="{html.escape(alt_canonical, quote=True)}">'
    else:
        alternate_tag = ""

    page_nav = ['<nav class="page-nav" aria-label="페이지 이동">']
    if previous:
        page_nav.append(
            f'<a href="{relative_link(page, previous)}"><span>{html.escape(labels["prev"])}</span>{html.escape(previous.title)}</a>'
        )
    else:
        page_nav.append("<div></div>")
    if following:
        page_nav.append(
            f'<a class="next" href="{relative_link(page, following)}"><span>{html.escape(labels["next"])}</span>{html.escape(following.title)}</a>'
        )
    else:
        page_nav.append("<div></div>")
    page_nav.append("</nav>")

    lang_switcher_html = render_lang_switch(page, alt_page, lang)

    return f"""<!doctype html>
<html lang="{lang}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{html.escape(page.title)} · {html.escape(toc["book"]["title"])}</title>
  <meta name="description" content="{html.escape(page.summary, quote=True)}">
  <link rel="canonical" href="{html.escape(canonical, quote=True)}">
  {alternate_tag}
  <link rel="icon" href="{html.escape(favicon_href, quote=True)}" type="image/svg+xml">
  <link rel="stylesheet" href="{html.escape(style_href, quote=True)}">
  <script src="{html.escape(script_href, quote=True)}" defer></script>
</head>
<body data-search-index="{html.escape(search_href, quote=True)}" data-site-root="{html.escape(site_root, quote=True)}" data-lang="{lang}">
  <div class="site-shell">
    <aside class="sidebar" id="sidebar">
      {render_sidebar(toc, page, page_by_wrapper, lang, alt_page)}
    </aside>
    <main class="main">
      <header class="topbar">
        <button class="menu-button" type="button" aria-controls="sidebar" aria-expanded="false">{html.escape(labels["menu"])}</button>
        <div class="crumb">{html.escape(page.chapter)} · {html.escape(page.title)}</div>
        <div class="topbar-actions">
          {lang_switcher_html}
          <a class="top-source" href="{html.escape(source_url(toc, page.content_source), quote=True)}" target="_blank" rel="noopener">{html.escape(labels["source_view"])}</a>
        </div>
      </header>
      <div class="content-layout">
        <div class="content-wrap">
          <p class="summary">{html.escape(page.summary)}</p>
          <div class="learning-actions">
            <span>{html.escape(labels["exec_flow"])}</span>
            <code>make test</code>
            <span>→</span>
            <code>PASS</code>
            <span>→ {html.escape(labels["interpret"])}</span>
          </div>
          <article>
            {content}
          </article>
          {''.join(page_nav)}
          <footer class="footer">
            <span>{html.escape(labels["source_prefix"])}{html.escape(page.content_source.relative_to(ROOT).as_posix())}</span>
            <a href="{html.escape(source_url(toc, page.content_source), quote=True)}" target="_blank" rel="noopener">{html.escape(labels["source_edit"])}</a>
          </footer>
        </div>
        {render_section_toc(headings, lang)}
      </div>
    </main>
  </div>
</body>
</html>
"""


def plain_search_text(markdown: str) -> str:
    text = re.sub(r"```.*?```", " ", markdown, flags=re.DOTALL)
    text = re.sub(r"`([^`]+)`", r"\1", text)
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    text = re.sub(r"[#>*_|\-]+", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def validate_generated_links() -> None:
    missing: list[str] = []
    for html_path in PUBLISH_DIR.rglob("*.html"):
        source = html_path.read_text(encoding="utf-8")
        for href in re.findall(r'(?:href|src)="([^"]+)"', source):
            if href.startswith(("http://", "https://", "mailto:", "#", "data:")):
                continue
            href_path = unquote(href.split("#", 1)[0].split("?", 1)[0])
            if not href_path:
                continue
            target = (html_path.parent / href_path).resolve()
            if not target.exists():
                missing.append(f"{html_path.relative_to(ROOT)} -> {href}")
    if missing:
        raise SystemExit("생성된 HTML에 끊어진 링크가 있습니다:\n" + "\n".join(missing))


def write_support_files(
    ko_toc: dict[str, Any],
    ko_pages: list[Page],
    en_toc: dict[str, Any],
    en_pages: list[Page],
) -> None:
    # 1. Korean search index
    ko_search_index = [
        {
            "id": page.id,
            "title": page.title,
            "summary": page.summary,
            "url": page.site_path,
            "chapter": page.chapter,
            "text": plain_search_text(page.body),
        }
        for page in ko_pages
    ]
    (PUBLISH_DIR / "search-index.json").write_text(
        json.dumps(ko_search_index, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    # 2. English search index
    en_search_index = [
        {
            "id": page.id,
            "title": page.title,
            "summary": page.summary,
            "url": page.site_path.replace("en/", "", 1),  # relative to en site root
            "chapter": page.chapter,
            "text": plain_search_text(page.body),
        }
        for page in en_pages
    ]
    (PUBLISH_DIR / "en" / "search-index.json").write_text(
        json.dumps(en_search_index, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    # 3. Build info
    version = (ROOT / "VERSION").read_text(encoding="utf-8").strip() if (ROOT / "VERSION").exists() else "1.0.0"
    build_info = {
        "title": ko_toc["book"]["title"],
        "title_en": en_toc["book"]["title"],
        "version": version,
        "languages": ["ko", "en"],
        "pages_total": len(ko_pages) + len(en_pages),
        "pages_ko": len(ko_pages),
        "pages_en": len(en_pages),
        "source_ko": "tutorial/**/README.md",
        "source_en": "tutorial_en/**/README.md",
    }
    (PUBLISH_DIR / "build-info.json").write_text(
        json.dumps(build_info, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    # 4. Sitemap with both languages
    site_url = str(ko_toc["book"]["site_url"]).rstrip("/")
    all_pages = ko_pages + en_pages
    sitemap_urls = "\n".join(f"  <url><loc>{site_url}/{page.site_path}</loc></url>" for page in all_pages)
    (PUBLISH_DIR / "sitemap.xml").write_text(
        f'<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n{sitemap_urls}\n</urlset>\n',
        encoding="utf-8",
    )

    # 5. Robots and .nojekyll
    (PUBLISH_DIR / "robots.txt").write_text(f"User-agent: *\nAllow: /\nSitemap: {site_url}/sitemap.xml\n", encoding="utf-8")
    (PUBLISH_DIR / ".nojekyll").write_text("", encoding="utf-8")


def build() -> None:
    ko_toc = read_toc(TOC_PATH)
    en_toc = read_toc(EN_TOC_PATH)

    ko_pages = load_pages(BOOK_DIR, ko_toc, TUTORIAL_DIR, lang="ko")
    en_pages = load_pages(EN_BOOK_DIR, en_toc, TUTORIAL_EN_DIR, lang="en")

    ko_page_by_wrapper = {page.wrapper_source.relative_to(BOOK_DIR).as_posix(): page for page in ko_pages}
    ko_page_by_content = {page.content_source.resolve(): page for page in ko_pages}

    en_page_by_wrapper = {page.wrapper_source.relative_to(EN_BOOK_DIR).as_posix(): page for page in en_pages}
    en_page_by_content = {page.content_source.resolve(): page for page in en_pages}

    ko_by_id = {page.id: page for page in ko_pages}
    en_by_id = {page.id: page for page in en_pages}

    if PUBLISH_DIR.exists():
        shutil.rmtree(PUBLISH_DIR)
    PUBLISH_DIR.mkdir(parents=True, exist_ok=True)
    (PUBLISH_DIR / "en").mkdir(parents=True, exist_ok=True)

    shutil.copy2(STYLE_PATH, PUBLISH_DIR / "webbook.css")
    shutil.copy2(SCRIPT_PATH, PUBLISH_DIR / "webbook.js")
    shutil.copy2(FAVICON_PATH, PUBLISH_DIR / "favicon.svg")

    # Render Korean pages
    for index, page in enumerate(ko_pages):
        page.output_dir.mkdir(parents=True, exist_ok=True)
        alt_page = en_by_id.get(page.id)
        rendered = render_page(ko_toc, ko_pages, index, ko_page_by_wrapper, ko_page_by_content, "ko", alt_page)
        page.output_path.write_text(rendered, encoding="utf-8")

    # Render English pages
    for index, page in enumerate(en_pages):
        page.output_dir.mkdir(parents=True, exist_ok=True)
        alt_page = ko_by_id.get(page.id)
        rendered = render_page(en_toc, en_pages, index, en_page_by_wrapper, en_page_by_content, "en", alt_page)
        page.output_path.write_text(rendered, encoding="utf-8")

    write_support_files(ko_toc, ko_pages, en_toc, en_pages)
    validate_generated_links()
    print(f"PASS webbook: {len(ko_pages)} KO + {len(en_pages)} EN = {len(ko_pages) + len(en_pages)} pages -> {PUBLISH_DIR}")


def configure_paths(args: argparse.Namespace) -> None:
    global ROOT, BOOK_DIR, EN_BOOK_DIR, TOC_PATH, EN_TOC_PATH, STYLE_PATH, SCRIPT_PATH, FAVICON_PATH, PUBLISH_DIR, TUTORIAL_DIR, TUTORIAL_EN_DIR
    ROOT = Path(args.root).resolve()
    BOOK_DIR = (ROOT / args.book_dir).resolve()
    EN_BOOK_DIR = BOOK_DIR / "en"
    TOC_PATH = (ROOT / args.toc).resolve()
    EN_TOC_PATH = (EN_BOOK_DIR / "toc.yml").resolve()
    STYLE_PATH = (ROOT / args.style).resolve()
    SCRIPT_PATH = (ROOT / args.script).resolve()
    FAVICON_PATH = (ROOT / args.favicon).resolve()
    PUBLISH_DIR = (ROOT / args.output).resolve()
    TUTORIAL_DIR = (ROOT / "tutorial").resolve()
    TUTORIAL_EN_DIR = (ROOT / "tutorial_en").resolve()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Verilog 자습서를 다국어(한국어/영어) 정적 웹북으로 생성합니다.")
    parser.add_argument("--root", default=".", help="저장소 루트")
    parser.add_argument("--book-dir", default="drafts/book", help="웹북 메타데이터 디렉터리")
    parser.add_argument("--toc", default="drafts/book/toc.yml", help="JSON 호환 목차 파일")
    parser.add_argument("--style", default="styles/webbook.css", help="웹북 CSS")
    parser.add_argument("--script", default="styles/webbook.js", help="웹북 JavaScript")
    parser.add_argument("--favicon", default="styles/favicon.svg", help="웹북 favicon")
    parser.add_argument("--output", default="publish/webbook", help="생성 결과 디렉터리")
    parser.add_argument("--check", action="store_true", help="생성 및 전체 검증 실행")
    return parser.parse_args()


if __name__ == "__main__":
    arguments = parse_args()
    configure_paths(arguments)
    build()
