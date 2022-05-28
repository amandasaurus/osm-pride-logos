#!/bin/bash
set -o errexit
set -o nounset

cd "$(dirname $0)" || exit

SIZES="500 100"

for FLAG in ./flags/*.svg ; do
    NAME=${FLAG}
    NAME=${NAME##.*/}
    NAME=${NAME%%.svg}
    OUTPUT=OSM_white_bg_with_small_border.${NAME}
    sed "s|FLAGFLAGFLAG|${FLAG}|" ./templates/logo_base.template.svg > OSM_white_bg_with_small_border.${NAME}.svg
    cat OSM_white_bg_with_small_border.${NAME}.svg | gzip > OSM_white_bg_with_small_border.${NAME}.svgz
    sed "s|FLAGFLAGFLAG|${FLAG}|" ./templates/logo_base_nb.template.svg > OSM_white_bg_with_small_border.nb.${NAME}.svg
	cat  OSM_white_bg_with_small_border.nb.${NAME}.svg | gzip > OSM_white_bg_with_small_border.nb.${NAME}.svg
    inkscape OSM_white_bg_with_small_border.${NAME}.svgz --export-dpi 300 --export-type="pdf" --export-background white --export-margin 3
    inkscape OSM_white_bg_with_small_border.nb.${NAME}.svgz --export-dpi 300 --export-type="pdf" --export-background white --export-margin 3

    inkscape OSM_white_bg_with_small_border.${NAME}.svgz --export-dpi 300 --export-type="pdf" --export-filename=tmp.pdf
    inkscape tmp.pdf --export-type="svg" --export-filename=OSM_white_bg_with_small_border.${NAME}.svg
	rm tmp.pdf
    cat OSM_white_bg_with_small_border.${NAME}.svg | gzip > OSM_white_bg_with_small_border.${NAME}.svgz

    for SIZE in $SIZES ; do
        inkscape OSM_white_bg_with_small_border.${NAME}.svgz -w $SIZE -h $SIZE --export-type="png" --export-filename=${OUTPUT}.${SIZE}.png --export-background white
        inkscape OSM_white_bg_with_small_border.nb.${NAME}.svgz -w $SIZE -h $SIZE --export-type="png" --export-filename=${OUTPUT}.${SIZE}.nb.png --export-background white
        pngquant -f --ext .png 128 ${OUTPUT}.${SIZE}.png
        pngquant -f --ext .png 128 ${OUTPUT}.${SIZE}.nb.png
    done
    echo "Done $NAME"
done

# alas this are broken, flag is all stretched
rm *.leather_bdsm.*png *bear*.png *intersex*.png

exiftool -overwrite_original -XMP-dc:Rights="This work is licensed to the public under the Creative Commons Attribution-ShareAlike license http://creativecommons.org/licenses/by-sa/4.0/" -xmp:usageterms="This work is licensed to the public under the Creative Commons Attribution-ShareAlike license http://creativecommons.org/licenses/by-sa/4.0/" -XMP-cc:license="http://creativecommons.org/licenses/by-sa/4.0/" -XMP-cc:AttributionName="Amanda McCann" -XMP-cc:AttributionURL="www.technomancy.org" *.png


rm -rf montage_images
mkdir montage_images
for FLAG in ./flags/*.svg ; do
    NAME=${FLAG}
    NAME=${NAME##.*/}
    NAME=${NAME%%.svg}
    if [ -f  ./OSM_white_bg_with_small_border.${NAME}.100.png ] ; then
        convert \( ./OSM_white_bg_with_small_border.${NAME}.100.png ./OSM_white_bg_with_small_border.${NAME}.100.nb.png +append \) -background white -gravity Center label:"${NAME}" -append ./montage_images/${NAME}.png
    fi
done
montage ./montage_images/*.png  -geometry 200x120 montage.png
rm -rf montage_images
