If your branch has new data you need to make sure that the Github automated tests (Github Actions) can test the model with these new data. To do so follow the steps:

1. run command:

tar -cvzf data.tgz *

in *bash* shell (run the command inside the folder that contains all data files, not from parent folder!)

2. upload data.tgz to Google Drive and share as "anyone with the link can view", copy link ID (string contained between slashes, after "d")

3. update (or ask an owner of the repo to do it for you) OPEN-PROM Github Actions secret "DATASET" with new link ID by replacing only the ID in the URL, not the full URL

4. open pull request for the change in step 3 or commit directly to main if you have access

6. merge updated main into branch to be merged  

7. create pull request (the automated tests triggered when a pull request is opened will run with the new dataset)
