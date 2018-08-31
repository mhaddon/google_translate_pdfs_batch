const puppeteer = require('puppeteer');
const args = process.argv;

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('https://translate.google.com/?tr=f&hl=' + args[3]);

  const fileInput = await page.$('input[name=file]');
  await fileInput.uploadFile(args[2]);

  await page.$eval("form[id='gt-form']", form => form.submit());
    
  await page.waitForNavigation();

  await page.pdf({ path: args[2] + '.translated.pdf', scale: 0.75, format: 'A4' });

  await browser.close();
})();
