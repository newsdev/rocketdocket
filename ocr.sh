#!/bin/bash

export OMP_THREAD_LIMIT=1

tesseract --oem 1 $1 out-$1 txt
