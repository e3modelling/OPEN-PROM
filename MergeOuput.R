MergeOutput <- function(name = "combined_plots") {
  "Merges all PNG plots from the working directory into a single PDF file"
  library(gridExtra)
  library(png)

  # Specify the folder containing the PNGs (adjust to your folder)
  png_files <- list.files(path = ".", pattern = "\\.png$", full.names = TRUE)

  # Check if PNG files exist
  if (length(png_files) == 0) {
    stop("No PNG files found in the folder!")
  }

  # Create a PDF file to store all the plots
  output_pdf <- paste0(name, ".pdf")
  pdf(output_pdf, width = 8, height = 6) # Set PDF dimensions

  # Loop through PNGs and add them to the PDF
  for (i in seq_along(png_files)) {
    file <- png_files[i]
    cat("Merging PNG:", file, "\n")
    img <- png::readPNG(file)
    grid::grid.raster(img)
    if (i < length(png_files)) grid::grid.newpage()
  }
  # Close the PDF device
  dev.off()

  cat("PDF created successfully:", output_pdf, "\n")
}
