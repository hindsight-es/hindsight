/**
 * Code Carousel - Simple tab-based carousel for code examples
 */

document.addEventListener('DOMContentLoaded', function() {
    const carousel = document.querySelector('.code-carousel');
    if (!carousel) return;

    const tabs = carousel.querySelectorAll('.carousel-tab');
    const panels = carousel.querySelectorAll('.carousel-panel');

    // Switch to a specific tab
    function switchTab(index) {
        // Update tabs
        tabs.forEach((tab, i) => {
            if (i === index) {
                tab.classList.add('active');
                tab.setAttribute('aria-selected', 'true');
            } else {
                tab.classList.remove('active');
                tab.setAttribute('aria-selected', 'false');
            }
        });

        // Update panels
        panels.forEach((panel, i) => {
            if (i === index) {
                panel.classList.add('active');
            } else {
                panel.classList.remove('active');
            }
        });
    }

    // Click handlers
    tabs.forEach((tab, index) => {
        tab.addEventListener('click', () => switchTab(index));
    });

    // Keyboard navigation
    carousel.addEventListener('keydown', function(e) {
        const currentIndex = Array.from(tabs).findIndex(tab =>
            tab.classList.contains('active')
        );

        let newIndex = currentIndex;

        if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
            newIndex = currentIndex > 0 ? currentIndex - 1 : tabs.length - 1;
            e.preventDefault();
        } else if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
            newIndex = currentIndex < tabs.length - 1 ? currentIndex + 1 : 0;
            e.preventDefault();
        } else if (e.key === 'Home') {
            newIndex = 0;
            e.preventDefault();
        } else if (e.key === 'End') {
            newIndex = tabs.length - 1;
            e.preventDefault();
        }

        if (newIndex !== currentIndex) {
            switchTab(newIndex);
            tabs[newIndex].focus();
        }
    });

    // Initialize first tab as active
    if (tabs.length > 0) {
        switchTab(0);
    }
});
