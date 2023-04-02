anvil_app=./AnvilApp
# copy files into back-up directory
echo "Copying laptop files into backup directory before syncing."
mkdir -p ./backup || exit 1
cp -r ./server_code ./backup
cp -r ./client_code ./backup

#cd "$app_on_laptop" || exit 1
#git commit -am "Before a pull from anvil.works"
echo "Git pull the anvil.works app.."
if ! git -C $anvil_app pull origin master; then
    echo "git pull errors initiated premature exit."
    exit 1
fi
echo "Copy anvil app code to project directories.."
if ! rsync -a --delete-after "$anvil_app"/client_code/ ./client_code; then
    echo "An error while syncing the anvil.works app client code to the project."
    exit 1
fi
rsync -a -v --delete-after "$anvil_app"/server_code/ ./server_code
cp "$anvil_app"/anvil.yaml .
echo "Regenerating _anvil_designer.py files in client_code.."
python -m _anvil_designer.generate_files
#
echo "git pull completed."
echo "If the database schema has changed, run yaml2schema.zsh"

