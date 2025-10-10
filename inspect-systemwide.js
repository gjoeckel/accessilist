const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch({ headless: false });
    const page = await browser.newPage();
    await page.setViewport({ width: 1920, height: 1080 });

    console.log('📏 Inspecting systemwide-report.php structure...\n');

    await page.goto('http://localhost:8000/systemwide-report', {
        waitUntil: 'networkidle2'
    });

    await new Promise(resolve => setTimeout(resolve, 2000));

    const structure = await page.evaluate(() => {
        const section = document.querySelector('.report-section');
        const allH2s = document.querySelectorAll('h2');
        const main = document.querySelector('main');

        return {
            hasSection: !!section,
            h2Count: allH2s.length,
            h2s: Array.from(allH2s).map(h2 => ({
                id: h2.id,
                className: h2.className,
                text: h2.textContent.substring(0, 50),
                width: h2.getBoundingClientRect().width,
                parentTag: h2.parentElement.tagName,
                parentClass: h2.parentElement.className
            })),
            mainChildren: Array.from(main.children).map(child => ({
                tag: child.tagName,
                className: child.className,
                id: child.id
            }))
        };
    });

    console.log('STRUCTURE:');
    console.log('Has .report-section:', structure.hasSection);
    console.log('Number of h2 elements:', structure.h2Count);
    console.log('\nAll H2 elements:');
    structure.h2s.forEach((h2, i) => {
        console.log(`  ${i + 1}. ID: "${h2.id}" | Class: "${h2.className}"`);
        console.log(`     Text: "${h2.text}"`);
        console.log(`     Width: ${h2.width}px`);
        console.log(`     Parent: <${h2.parentTag} class="${h2.parentClass}">`);
    });

    console.log('\nMain children:');
    structure.mainChildren.forEach((child, i) => {
        console.log(`  ${i + 1}. <${child.tag} class="${child.className}" id="${child.id}">`);
    });

    await new Promise(resolve => setTimeout(resolve, 10000));
    await browser.close();
})();

