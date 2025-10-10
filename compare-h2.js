const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch({ headless: false });
    const page = await browser.newPage();
    await page.setViewport({ width: 1920, height: 1080 });

    // Get session key
    await page.goto('http://localhost:8000/mychecklist?type=word', {
        waitUntil: 'networkidle2'
    });

    const sessionKey = await page.evaluate(() => {
        return window.sessionKeyFromPHP || window.unifiedStateManager?.sessionKey;
    });

    // Measure list-report.php
    console.log('📏 LIST-REPORT.PHP H2:\n');
    await page.goto(`http://localhost:8000/list-report?session=${sessionKey}`, {
        waitUntil: 'networkidle2'
    });

    const listReportH2 = await page.evaluate(() => {
        const h2 = document.querySelector('.report-section h2');
        const styles = window.getComputedStyle(h2);
        const rect = h2.getBoundingClientRect();

        return {
            id: h2.id,
            width: rect.width,
            offsetWidth: h2.offsetWidth,
            maxWidth: styles.maxWidth,
            width_css: styles.width,
            textAlign: styles.textAlign,
            display: styles.display,
            marginLeft: styles.marginLeft,
            marginRight: styles.marginRight,
            paddingLeft: styles.paddingLeft,
            paddingRight: styles.paddingRight
        };
    });

    console.log('ID:', listReportH2.id);
    console.log('Width (computed):', listReportH2.width + 'px');
    console.log('Width (CSS):', listReportH2.width_css);
    console.log('Max-width:', listReportH2.maxWidth);
    console.log('Display:', listReportH2.display);
    console.log('Text-align:', listReportH2.textAlign);
    console.log('Margin L/R:', listReportH2.marginLeft, '/', listReportH2.marginRight);
    console.log('Padding L/R:', listReportH2.paddingLeft, '/', listReportH2.paddingRight);

    // Measure systemwide-report.php
    console.log('\n📏 SYSTEMWIDE-REPORT.PHP H2:\n');
    await page.goto('http://localhost:8000/systemwide-report', {
        waitUntil: 'networkidle2'
    });

    const systemwideH2 = await page.evaluate(() => {
        const h2 = document.querySelector('#reports-caption');
        if (!h2) {
            return { error: 'H2 not found' };
        }
        const styles = window.getComputedStyle(h2);
        const rect = h2.getBoundingClientRect();

        return {
            id: h2.id,
            width: rect.width,
            offsetWidth: h2.offsetWidth,
            maxWidth: styles.maxWidth,
            width_css: styles.width,
            textAlign: styles.textAlign,
            display: styles.display,
            marginLeft: styles.marginLeft,
            marginRight: styles.marginRight,
            paddingLeft: styles.paddingLeft,
            paddingRight: styles.paddingRight
        };
    });

    console.log('ID:', systemwideH2.id);
    console.log('Width (computed):', systemwideH2.width + 'px');
    console.log('Width (CSS):', systemwideH2.width_css);
    console.log('Max-width:', systemwideH2.maxWidth);
    console.log('Display:', systemwideH2.display);
    console.log('Text-align:', systemwideH2.textAlign);
    console.log('Margin L/R:', systemwideH2.marginLeft, '/', systemwideH2.marginRight);
    console.log('Padding L/R:', systemwideH2.paddingLeft, '/', systemwideH2.paddingRight);

    console.log('\n📊 COMPARISON:');
    console.log(`   List-report h2: ${listReportH2.width.toFixed(2)}px`);
    console.log(`   Systemwide h2: ${systemwideH2.width.toFixed(2)}px`);
    console.log(`   Difference: ${Math.abs(listReportH2.width - systemwideH2.width).toFixed(2)}px\n`);

    await new Promise(resolve => setTimeout(resolve, 10000));
    await browser.close();
})();

