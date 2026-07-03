function addResizeHandler(resizeContainer, layoutContainer, widthProperty, direction) {
    if (!resizeContainer) {
        return;
    }
    const resizeData = {
        tracking: false,
        startWidth: null,
        startCursorScreenX: null,
    };

    const handler = document.createElement("div");
    handler.classList.add("resize-handler");
    if (direction === "left") {
        resizeContainer.appendChild(handler);
    } else {
        resizeContainer.insertBefore(
            handler,
            resizeContainer.firstElementChild,
        );
    }

    handler.addEventListener("mousedown", (event) => {
        if (event.button !== 0) {
            return;
        }

        event.preventDefault();
        event.stopPropagation();

        resizeData.startWidth = parseFloat(
            getComputedStyle(resizeContainer).getPropertyValue("width"),
        );
        resizeData.startCursorScreenX = event.screenX;
        resizeData.tracking = true;
        resizeData.handler = handler;
        handler.classList.add("active");
    });

    window.addEventListener("mousemove", (event) => {
        if (!resizeData.tracking) {
            return;
        }
        const cursorScreenXDelta =
            event.screenX - resizeData.startCursorScreenX;
        const newWidth =
            resizeData.startWidth +
            cursorScreenXDelta * (direction === "left" ? 1 : -1);

        layoutContainer.style.setProperty(widthProperty, `${Math.max(0, newWidth)}px`);
    });

    window.addEventListener("mouseup", () => {
        if (!resizeData.tracking) {
            return;
        }
        resizeData.tracking = false;

        handler.classList.remove("active");
    });
}

function setUpResizeContainers() {
    const container = document.body.querySelector("pb-page");
    if (!container) {
        return;
    }
    const before = container.querySelector(".fixed-layout > .before");

    addResizeHandler(before, container, "--jinks-layout-before-width", "left");

    const after = container.querySelector(".fixed-layout > .after");
    addResizeHandler(after, container, "--jinks-layout-after-width", "right");
}

function markStaticSidebarLayout() {
    const page = document.body.querySelector("pb-page");
    if (!page || !document.body.classList.contains("static")) {
        return;
    }
    const after = page.querySelector(":scope > .after");
    if (after?.querySelector(".tab-panel") && !after.classList.contains("after-tabs")) {
        after.classList.add("after-tabs");
    }
    const before = page.querySelector(":scope > .before");
    if (before && !before.classList.contains("hidden")) {
        const hasContent = [...before.children].some(
            (el) =>
                !el.classList.contains("resize-handler") &&
                (el.textContent || "").trim(),
        );
        if (!hasContent) {
            before.classList.add("hidden");
        }
    }
}

function resetAfterTabs() {
    const container = document.querySelector(".after.after-tabs");
    if (!container) {
        return;
    }
    container.querySelector(".after-tab-nav")?.remove();
    container.querySelectorAll(":scope > .tab-panel").forEach((panel) => {
        panel.hidden = false;
        panel.removeAttribute("hidden");
        const titleEl = panel.querySelector(":scope > .tab-title");
        if (titleEl) {
            titleEl.hidden = false;
            titleEl.removeAttribute("hidden");
        }
    });
}

function initAfterTabs() {
    const container = document.querySelector(".after.after-tabs");
    if (!container) {
        return;
    }
    const panels = [...container.querySelectorAll(":scope > .tab-panel")];
    if (panels.length === 0) {
        return;
    }

    const existingNav = container.querySelector(".after-tab-nav");
    if (existingNav && existingNav.querySelectorAll(".after-tab-btn").length === panels.length) {
        return;
    }
    if (existingNav) {
        resetAfterTabs();
    }

    const nav = document.createElement("nav");
    nav.className = "after-tab-nav";
    nav.setAttribute("role", "tablist");
    nav.setAttribute("aria-label", "Sidebar tabs");
    panels.forEach((panel, i) => {
        const panelId = `after-tab-panel-${i}`;
        panel.id = panelId;
        const titleEl = panel.querySelector(":scope > .tab-title");
        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "after-tab-btn" + (i === 0 ? " active" : "");
        btn.setAttribute("role", "tab");
        btn.setAttribute("aria-controls", panelId);
        btn.setAttribute("aria-selected", i === 0 ? "true" : "false");
        if (titleEl) {
            const label = (titleEl.getAttribute("data-title") || titleEl.textContent || "")
                .replace(/\s+/g, " ")
                .trim();
            btn.textContent = label;
            titleEl.hidden = true;
        }
        btn.addEventListener("click", () => {
            panels.forEach((p) => {
                p.hidden = true;
            });
            nav.querySelectorAll(".after-tab-btn").forEach((b) => {
                b.classList.remove("active");
                b.setAttribute("aria-selected", "false");
            });
            panel.hidden = false;
            btn.classList.add("active");
            btn.setAttribute("aria-selected", "true");
            panel.querySelectorAll("pb-view, pb-facsimile, pb-tify").forEach((el) => {
                if (typeof el.refresh === "function") {
                    el.refresh();
                }
            });
        });
        nav.appendChild(btn);
        panel.hidden = i !== 0;
    });
    panels[0].before(nav);
}

function runStaticLayoutFix() {
    if (!document.body.classList.contains("static")) {
        return;
    }
    markStaticSidebarLayout();
    initAfterTabs();
}

function setupLayoutUi() {
    const asideToggles = document.querySelectorAll(".aside-toggle");
    asideToggles.forEach((toggle) => {
        const mobileToggle = toggle.classList.contains("mobile");
        const hiddenClass = mobileToggle ? "hidden-mobile" : "hidden";
        toggle.addEventListener("click", function () {
            toggle.classList.toggle("open");
            const target = this.dataset.toggle;
            const targetElement = document.querySelector(target);
            targetElement.classList.toggle(hiddenClass);
            if (mobileToggle) {
                document.querySelector(".fixed-layout > main").classList.toggle(hiddenClass);
            }
            const topPanel = this.closest(
                ".fixed-layout > .before-top,.fixed-layout > .after-top",
            );
            if (topPanel) {
                topPanel.classList.toggle(hiddenClass);
            }
        });
    });

    const mobileMenuToggle = document.querySelector(".mobile.trigger button");
    if (mobileMenuToggle) {
        mobileMenuToggle.addEventListener("click", function () {
            const target = this.dataset.toggle;
            const targetElement = document.querySelector(target);
            targetElement.classList.toggle("hidden");
        });
    }

    const mobileAsideToggles = document.querySelectorAll(".aside-toggle.mobile");
    if (mobileAsideToggles.length > 0) {
        document.addEventListener("pb-refresh", function () {
            mobileAsideToggles.forEach((toggle) => {
                const target = toggle.dataset.toggle;
                if (target) {
                    const targetElement = document.querySelector(target);
                    if (targetElement && !targetElement.classList.contains("hidden-mobile")) {
                        targetElement.classList.add("hidden-mobile");
                        toggle.classList.remove("open");
                    }
                    const topPanel = toggle.closest(
                        ".fixed-layout > .before-top,.fixed-layout > .after-top",
                    );
                    if (topPanel && !topPanel.classList.contains("hidden-mobile")) {
                        topPanel.classList.add("hidden-mobile");
                    }
                    const main = document.querySelector(".fixed-layout > main");
                    if (main && !main.classList.contains("hidden-mobile")) {
                        main.classList.add("hidden-mobile");
                    }
                }
            });
        });
    }

    setUpResizeContainers();
}

document.addEventListener("DOMContentLoaded", function () {
    runStaticLayoutFix();
    setupLayoutUi();
});

document.addEventListener("pb-page-ready", runStaticLayoutFix);
customElements.whenDefined("pb-page").then(() => {
    requestAnimationFrame(runStaticLayoutFix);
});

document.addEventListener("click", (e) => {
    const summary = e.target.closest("summary");
    if (summary) {
        const currentDetails = e.target.closest("details");
        const allDetails = document.querySelectorAll("details.dropdown, details.dropdown-button");
        allDetails.forEach((details) => {
            if (details !== currentDetails) {
                details.removeAttribute("open");
            }
        });
    } else if (!e.target.closest("details")) {
        const allDetails = document.querySelectorAll(
            "details[open].dropdown, details[open].dropdown-button",
        );
        allDetails.forEach((details) => {
            details.removeAttribute("open");
        });
    }
});
