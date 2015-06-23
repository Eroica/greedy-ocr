LANGUAGE = "deu-frak"
LANGUAGE_NAME = "fraktur"
TESSERACT_OPTIONS = "-psm 7"
OUTPUT_DIR = "../test"

cd $OUTPUT_DIR

for file in *.tif; do
    tesseract $file ${file%.*} box.train $TESSERACT_OPTIONS
done

unicharset_extractor *.box
echo "fraktur 0 0 0 0 1" > font_properties
shapeclustering -F font_properties -U unicharset *.tr
mftraining -F font_properties -U unicharset -O deu-frak.unicharset *.tr
cntraining *.tr

mv shapetable deu-frak.shapetable
mv normproto deu-frak.normproto
mv inttemp deu-frak.inttemp
mv pffmtable deu-frak.pffmtable

combine_tessdata deu-frak.
