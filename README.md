# ROCKETDOCKET

OCRing a PDF requires a few steps if you'd like to do it in parallel.

Currently, we're taking in a single large PDF and producing a single text file for each page.

Decisions should be made about what to do with those text files. Put 'em in Elasticsearch? Combine them back into a giant PDF? Both? Neither?

## Ghostscript
```
time gs\
    -o file-%05d.png\
    -sDEVICE=pngmono\
    -dNumRenderingThreads=$(sysctl -n hw.ncpu)\
    -dBandHeight=100\
    -dBufferSpace=1000000000\
    -dBandBufferSpace=500000000\
    -sBandListStorage=memory\
    -dBATCH\
    -dNOPAUSE\
    -dNOGC\ 
    -r72\
    original.pdf
```

### Explanation
* `-o file-%05d.png`: Outputs file names like `file-00405.png`, one for each page.
* `-dNumRenderingThreads=$(sysctl -n hw.ncpu)`: Makes a thread for every CPU (or virtual CPU) your computer claims to have.
* `-sDEVICE=pngmono`: The fastest output, in my testing, is with the `pngmono` engine, which is a black-and-white PNG with no transparency. PNG is also the fastest for Tesseract to process.
* `-dBandHeight=100 -dBufferSpace=1000000000 -dBandBufferSpace=500000000 -sBandListStorage=memory`: Sets up a large amount of memory for creating PNGs.
* `-dBATCH -dNOPAUSE -dNOGC`: From the internet, things you can turn off to increase speed.
* `-r72`: Produces a 72-dpi PNG image. Smaller numbers here are faster to generate, but OCR quality decreases quite a bit as you descend below this.

## Tesseract
```
time ls *.png | xargs -n 1 -P $(sysctl -n hw.ncpu) ./ocr.sh
```

### Explanation
* `ls *.png`: Produces output where each filename is on a single line.
* `| xargs`: Takes the output of `ls *.png` and feeds it to `xargs`
* `-n 1`: Each line contains something we'd like to process, aka, a PNG file path.
* `-P $(sysctl -n hw.ncpu)`: `xargs` should use one process per CPU (or virtual CPU) your computer claims to have.
* `./ocr.sh`: Runs whatever is in `ocr.sh` with the name of the PNG file as the argument.