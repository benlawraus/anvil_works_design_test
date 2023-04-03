current_dir=$(pwd)
anvil_app="$current_dir"/AnvilApp
if [ $# -eq 2 ]
  then
    anvil_app=$1
    current_dir=$2
else
    echo "No arguments supplied. Using:
     ${anvil_app}
     ${current_dir}"
fi

# copy files into back-up directory
echo "Copying laptop files into backup directory before syncing."
mkdir -p "$current_dir"/tests/backup || exit 1
cp -r "$current_dir"/server_code "$current_dir"/tests/backup
cp -r "$current_dir"/client_code "$current_dir"/tests/backup

#cd "$app_on_laptop" || exit 1
#git commit -am "Before a pull from anvil.works"
echo "Git pull the anvil.works app.."
if ! git -C "$anvil_app" pull origin master; then
    echo "git pull errors initiated premature exit."
    exit 1
fi
echo "Copy anvil app code to project directories.."
if ! rsync -a --delete-after "$anvil_app"/client_code/ "$current_dir"/client_code; then
    echo "An error while syncing the anvil.works app client code to the project."
    exit 1
fi
rsync -a -v --delete-after "$anvil_app"/server_code/ "$current_dir"/server_code
cp "$anvil_app"/anvil.yaml "$current_dir"/anvil.yaml
echo "Regenerating _anvil_designer.py files in client_code.."
python -m _anvil_designer.generate_files
#
echo "git pull completed."
echo "If the database schema has changed, run yaml2schema.zsh"

