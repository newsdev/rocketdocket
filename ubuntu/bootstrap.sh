#!/bin/bash

# install tools
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get -y install ghostscript imagemagick tesseract-ocr

# create a working directory
mkdir pdf

# create ocr script
cat <<EOF > pdf/ocr.sh
#!/bin/bash
export OMP_THREAD_LIMIT=1
tesseract --oem 1 \$1 out-\$1 txt
EOF
chmod +x pdf/ocr.sh

# create single output file script
cat <<EOF > pdf/combine.sh
#!/bin/bash
page=0
for f in ./*.txt; do
  ((page+=1))
  printf "\n==================== Page \$page ====================\n" >> complete.txt
  cat \$f >> complete.txt
done
EOF
chmod +x pdf/combine.sh

# create the main script
cat <<EOF > pdf/pdf.sh
#!/bin/bash

P=\$(cat /proc/cpuinfo | grep processor | wc -l)

# download file
gsutil cp \$1 original.pdf

# generate png for each page
gs -o file-%05d.png -sDEVICE=pngmono -dNumRenderingThreads=\$P -dBandHeight=100 -dBufferSpace=1000000000 -dBandBufferSpace=500000000 -sBandListStorage=memory -dBATCH -dNOPAUSE -dNOGC -r96 original.pdf

# ocr each png
ls *.png | xargs -n 1 -P \$P ./ocr.sh

# combine into one txt file
./combine.sh
EOF
chmod +x pdf/pdf.sh