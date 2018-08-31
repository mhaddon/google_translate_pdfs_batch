### Batch translate PDFs with Google Translate

This application uses Google Translate for PDFs in order to translate a batch of PDFs in a directory.

Google Translate has a 1mb limit per upload, so PDFs are uploaded and translated one page at a time, then reassembled afterwards.

#### Setup and Install

Install the following:

- node
- chrome
- Poppler - https://formulae.brew.sh/formula/poppler 

```
git clone https://github.com/mhaddon/google_translate_pdfs_batch.git
cd google_translate_pdfs_batch
npm install
```

optional: add google_translate_pdfs_batch to PATH

#### Usage

```
translate.sh $PATH_TO_PDF(S) $LANGUAGE
```

$LANGUAGE is the 2 digit ISO code for languages.

$LANGUAGE defaults to en (for english) if unspecified.

#### Miscellaneous

The default system is converting the HTML result from Google Translate to pdf to easily compact it.

In theory you can convert to an image instead which can have different effects on the layout.

In index.js you can change `await page.pdf` to `await page.screenshot({ path: args[2] + '.translated.png', fullPage: true });`

And change the pdfunite in translate.sh to `convert $(find "${PARTS_FOLDER}" -type f -name "*.translated.png") "${OUTPUT_PATH}"`

This will require imagemagick.

To open all the files automatically you can do:

```
translate.sh $PATH_TO_PDFS en | while read -r FILE; do open $FILE; done
```
