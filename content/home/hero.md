+++
# Hero widget.
widget = "hero"  # See https://sourcethemes.com/academic/docs/page-builder/
headless = true  # This file represents a page section.
active = false # Activate this widget? true/false
weight = 1  # Order that this section will appear.
title = ""

# Hero image (optional). Enter filename of an image in the `static/media/` folder.
hero_media = "Toad.png"

[design.background]
  # Apply a background color, gradient, or image.
  #   Uncomment (by removing `#`) an option to apply it.
  #   Choose a light or dark text color by setting `text_color_light`.
  #   Any HTML color name or Hex value is valid.

  # Background color.
  # color = "#fff"
  
  # Background gradient.
  # gradient_start = "#4bb4e3"
  # gradient_end = "#000"
  
  # Background image.
  # image = ""  # Name of image in `static/media/`.
  # image_darken = 0.6  # Darken the image? Range 0-1 where 0 is transparent and 1 is opaque.

  # Text color (true=light or false=dark).
  text_color_light = false

# Call to action links (optional).
#   Display link(s) by specifying a URL and label below. Icon is optional for `[cta]`.
#   Remove a link/note by deleting a cta/note block.
[butn]
  url = "/authors/ErikKusch"
  label = "About me"
  
# [butn_alt]
#   url = "#contact"
#   label = "Contact me"

+++

## Hi. I'm **Erik Kusch**, a senior engineer at the [Natural History Museum of the University of Oslo](https://www.nhm.uio.no/english/) where I manage research infrastructure for the [BioDT project](https://biodt.eu/).

Using big data and generating novel statistical methodology, I aim to understand how global and local processes and patterns in biological systems come about and are reinforced thus generating knowledge about the resilience of the Earth's ecosystems. 

My PhD project at [Aarhus University](https://international.au.dk/) focused on ecological interactions and the networks they form at macroecological scales.

<style>
.butn {
  background-color: inherit;
  padding: 14px;
  border-radius: 0px;
  border-width: 2px;
  border-style: solid;
  border-color: green;
  font-size: inherit;
  cursor: pointer;
  display: inline-block;
}

/* On mouse-over */
.butn:hover {background: #eee;}

.success {background-color: forestgreen;}
.info {background-color: #67da6f;}
.warning {background-color: orange;}
.danger {background-color: red;}
.default {background-color: inherit;}

}
</style>


<button class="butn default">[About Me](about)</button>
<button class="butn default">[Reach Me](contact)</button>