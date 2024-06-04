import os 
import zipfile


def list_subfolders(base_dir):
    """
    Input: None
    Output: A list of tuples containing subfolder names and their corresponding creation times, sorted based on their creation times.
    """

    subfolders = [(f.name, os.path.getctime(f.path)) for f in sorted(os.scandir(base_dir), key=lambda x: os.path.getctime(x.path), reverse=True) if f.is_dir()]
   
    return subfolders

# Function to compress a file
def compress_file(file_path):
    zip_file_path = f"{file_path}.zip"
    with zipfile.ZipFile(zip_file_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        zipf.write(file_path, os.path.basename(file_path))


# Function to compress blabla.gdx files in all subfolders of the given base directory
def compress_blabla_files(base_dir):


    # Get the list of subfolders
    subfolders = list_subfolders(base_dir)

    if not subfolders:
        print("No subfolders found.")
        return

    # Get the latest subfolder
    latest_folder_name, _ = subfolders[0]
    folder_path = os.path.join(base_dir, latest_folder_name)
    
    # Process the latest subfolder
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file == "blabla.gdx":
                file_path = os.path.join(root, file)
                zip_file_path = f"{file_path}.zip"
                if not os.path.exists(zip_file_path):
                    print(f"Compressing {file_path}...")
                    compress_file(file_path)
                    print(f"Compressed {file_path} into {zip_file_path}")
                else:
                    print(f"Zip file already exists for {file_path}, skipping compression.")


if __name__ == "__main__":

    # Define the base directory
    base_dir = "runs"

    # Call the main function
    path = compress_blabla_files(base_dir)