#!/bin/sh
echo "Starting dummy data download..."
curl -L -o dummy_data.tgz "https://drive.usercontent.google.com/u/0/uc?id=1YTO3jaqFbZJ5x_J2JfSsVYljXtHBHk0p&export=download"

if [ $? -eq 0 ]; then
    echo "Download completed successfully."
    mkdir -p ./data
    echo "Starting extraction..."
    tar -xzf dummy_data.tgz -C ./data
    echo "Extraction completed."
else
    echo "Download failed."
fi