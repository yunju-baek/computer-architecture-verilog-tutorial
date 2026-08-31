(() => {
  const body = document.body;
  const menuButton = document.querySelector(".menu-button");
  const sidebar = document.querySelector(".sidebar");

  if (menuButton && sidebar) {
    menuButton.addEventListener("click", () => {
      const open = body.classList.toggle("nav-open");
      menuButton.setAttribute("aria-expanded", String(open));
    });
    sidebar.querySelectorAll("a").forEach((link) => {
      link.addEventListener("click", () => {
        body.classList.remove("nav-open");
        menuButton.setAttribute("aria-expanded", "false");
      });
    });
  }

  document.querySelectorAll(".copy-code").forEach((button) => {
    button.addEventListener("click", async () => {
      const code = button.parentElement?.querySelector("code")?.textContent ?? "";
      await navigator.clipboard.writeText(code);
      button.textContent = "복사됨";
      window.setTimeout(() => {
        button.textContent = "복사";
      }, 1400);
    });
  });

  const searchInput = document.querySelector("#book-search");
  const searchResults = document.querySelector("#search-results");
  const searchIndexUrl = body.dataset.searchIndex;
  const siteRoot = body.dataset.siteRoot ?? "./";
  let pages = [];

  const normalize = (value) => value.toLocaleLowerCase("ko-KR").replace(/\s+/g, " ").trim();

  const scorePage = (page, terms) => {
    const title = normalize(page.title);
    const summary = normalize(page.summary);
    const text = normalize(page.text);
    let score = 0;
    for (const term of terms) {
      if (!text.includes(term) && !title.includes(term) && !summary.includes(term)) return 0;
      if (title.includes(term)) score += 12;
      if (summary.includes(term)) score += 6;
      if (text.includes(term)) score += 1;
    }
    return score;
  };

  const renderResults = (query) => {
    if (!searchResults) return;
    searchResults.replaceChildren();
    const terms = normalize(query).split(" ").filter(Boolean);
    if (terms.length === 0) {
      searchResults.classList.remove("visible");
      return;
    }

    const matches = pages
      .map((page) => ({ page, score: scorePage(page, terms) }))
      .filter((item) => item.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, 8);

    if (matches.length === 0) {
      const empty = document.createElement("p");
      empty.className = "search-empty";
      empty.textContent = "검색 결과가 없습니다.";
      searchResults.append(empty);
    } else {
      for (const { page } of matches) {
        const link = document.createElement("a");
        link.href = `${siteRoot}${page.url}`;
        const title = document.createElement("strong");
        title.textContent = page.title;
        const summary = document.createElement("span");
        summary.textContent = page.summary;
        link.append(title, summary);
        searchResults.append(link);
      }
    }
    searchResults.classList.add("visible");
  };

  if (searchInput && searchResults && searchIndexUrl) {
    fetch(searchIndexUrl)
      .then((response) => {
        if (!response.ok) throw new Error(`search index: ${response.status}`);
        return response.json();
      })
      .then((data) => {
        pages = data;
        searchInput.addEventListener("input", (event) => renderResults(event.target.value));
      })
      .catch(() => {
        searchInput.placeholder = "검색 색인 준비 중";
      });
  }
})();
