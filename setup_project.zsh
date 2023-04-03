myAnvilGit="ssh://youranvilworksusername@anvil.works:2222/gobblygook.git"

echo "What this script does:"
echo "Installs the git submodules:"
echo "  your anvil.works app (using \$myAnvilGit)"
echo "  yaml2schema (to setup database)"
echo "  anvil - a mock of the anvil.works classes and functions"
echo "  _anvil_designer - python files to generate UI auto-complete for client_code and database tables."
echo "  anvil_extras - WORK-IN_PROGRESS a mock of anvil_extras"
echo "Sets up a virtualenv. In the virtualenv it pip installs:"
echo "  pyDAL  (the database abstraction layer)"
echo "  stringyaml (to parse yaml files)"
echo "  pytest"
echo "  Parallel pytest helper"
echo "Uses yaml2schema to setup database."
echo "Copies the files from the anvil app to the project directories"
echo "Generates the _anvil_designer.py files for UI auto-complete."
echo "Creates scripts for push and pull to anvil server."

if [ $# -eq 1 ]
  then
    myAnvilGit=$1
else
    echo "myAnvilGit not an argument. Using:"
    echo "${myAnvilGit}"
fi

# what your anvil app is called
current_dir=$(pwd)
anvil_app="$current_dir"/AnvilWorksApp
# setopt interactivecomments
# allow comments for zsh
# Create new rep
git remote remove origin

echo "git clone the Anvil App .."
if ! git clone "$myAnvilGit" "$anvil_app"; then
    echo "Errors occurred trying to clone ${myAnvilGit}. Exiting."
    exit 1
fi

echo "cp anvil.yaml .."
cp "$anvil_app"/anvil.yaml "$current_dir"/ || exit 1

# create a virtualenv
echo "Create virtualenv .."
if ! python3 -m venv ./venv; then
    exit 1
fi
echo "Activate virtualenv ${VIRTUAL_ENV} .."
source venv/bin/activate
if ! [[ $VIRTUAL_ENV = *"$current_dir"* ]]; then
    echo "Could not activate virtual_env. Exiting."
    exit 1
fi

# these are used by yaml2schema
# pip3 install datamodel-code-generator # lets not generate class models, do not need them.
if ! pip3 install strictyaml; then
  echo "pip3 errors while installing strictyaml"
  exit 1
fi
# install these dependencies
pip3 install pyDAL
pip3 install pytest
pip3 install pytest-tornasync

date
git_push="$current_dir"/git_push_to_anvil_works.zsh
git_pull="$current_dir"/git_pull_from_anvil_works.zsh
yaml_convert="$current_dir"/yaml2schema.zsh
echo "make scripts executable .."
chmod +x "$yaml_convert" || exit 1
chmod +x "$git_pull" || exit 1
chmod +x "$git_push" || exit 1

# generate pydal_def.py
echo "Generate pydal_def.py in the tests directory (running $(basename $yaml_convert).."
if ! "$yaml_convert"; then
    echo "Errors occurred. Exiting."
    exit 1
fi


echo "Copy server and client files (running $(basename $git_pull).."
if ! "$git_pull" ; then
    echo "Errors occurred. Exiting."
    exit 1
fi
cd "$current_dir" || exit 1
echo "Generate all the _anvil_designer.py files for every form."
if ! python3 -m _anvil_designer.generate_files; then
  echo "Crashed while regenerating the _anvil_designer.py files."
    exit 1
fi
