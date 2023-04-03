echo "~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~  -  ~"
current_dir=$(pwd)
yaml2schema="$current_dir"/yaml2schema
anvil_app="current_dir"/AnvilApp
echo "Copies anvil.yaml from ${anvil_app} and generates a new pydal_def.py in tests."
echo "Also, updates AppTables.py to reflect correct table names with their column names and types."
# check that directories exists, exit otherwise
if [ ! -d "$yaml2schema" ]; then
  echo "${yaml2schema} not there. Use https://github.com/benlawraus/yaml2schema"
  exit 1
fi
if [ ! -d "$current_dir" ]; then
  echo "${current_dir} not there.
This is your development space and should contain all the tools."
  exit 1
fi
if [ ! -d "$anvil_app" ]; then
  echo "${anvil_app}  not there. git your app from anvil.works."
  exit 1
fi
# copy anvil.yaml and anvil_refined.yaml (anvil_refined.yaml lives in . )
anvil_refined_yaml=$current_dir/anvil_refined.yaml
echo "Using anvil.yaml and ${anvil_refined_yaml} to generate pydal_def.py"
#rm "$yaml2schema"/src/yaml2schema/input/*.yaml
cp "$anvil_app"/anvil.yaml ./input/ || exit 1
if ! cp "$current_dir"/anvil_refined.yaml ./input/; then
  echo "No anvil_refined.yaml. Continuing..."
fi
if ! [[ $VIRTUAL_ENV = *"${current_dir}"* ]]; then
  echo "No virtual env is activated."
  exit 1
fi

# check that everything went ok
echo "Use yaml2schema .."
if ! python3 "$yaml2schema"/src/yaml2schema/main.py; then
    echo "pydal_def not generated. yaml2schema interrupted."
    exit 1
fi
# copy the pyDAL definition file to app
if ! cp ./output/pydal_def.py "$current_dir"/tests/; then
  echo "Create tests directory .."
  mkdir "$current_dir"/tests || exit 1
  mkdir "$current_dir"/tests/database || exit 1
  cp "$yaml2schema"/src/yaml2schema/output/pydal_def.py "$current_dir"/tests/ || exit 1
fi
echo "Erasing current database."
rm -f "$current_dir"/tests/database/*.table
rm -f "$current_dir"/tests/database/*.log
rm -f "$current_dir"/tests/database/*.sqlite
echo "Generating new pydal database schema (pydal_def.py)."
# check that directories are there and writable
if ! python3 tests/pydal_def.py; then
    echo "Error when generating database files. Exiting."
    exit 1
fi
# Generate AppTables
if ! python3 -m _anvil_designer.generate_apptable; then
  echo "Crashed while generating AppTable.py."
    exit 1
fi

exit 0
