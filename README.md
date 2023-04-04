SUMMARY
=======
To assist with coding (with auto-complete) and testing  of an [anvil.works](https://anvil.works) app within an IDE such as [PyCharm](https://www.jetbrains.com/pycharm/).


Uses [_anvil_designer](https://github.com/benlawraus/_anvil_designer) and [yaml2schema](https://github.com/benlawraus/yaml2schema)
to generate a pseudo-front-end and a back-end on a local machine. After installation, no internet connection is required to run tests, as the database is replicated in sqlite.


Install
========
This is basically an empty project. Clone it using::

    git clone https://github.com/benlawraus/anvil_works_design_test --recursive
    mv anvil_works_design_test myProject
    cd myProject
    vi setup_project.zsh  # change the first line to your anvil.works app link
    chmod +x setup_project.zsh
    ./setup_project.zsh

**Before executing the script**, change the first line in the script from:

    myAnvilGit="ssh://youranvilworksusername@anvil.works:2222/gobblygook.git"

to your actual anvil.works app link found from your anvil.works account.

After ``setup_project.zsh`` is finished::

    source venv/bin/activate
    python3 -m pytest tests

This will run a test to make sure your test user can log in and out.

Use
===
Once `setup_project.zsh` is finished, the app can be developed further within an IDE such as [PyCharm](https://www.jetbrains.com/pycharm/). The front-end code is in `client_code` and the server code is in `server_code`. `pytest` code can be placed in a separate tests directory and run::

    python3 -m pytest tests_project

Some example tests are in the anvil apps [cached_lists_anvil_works](https:github.com/benlawraus/cached_lists_anvil_works) and [pyDALAnvilWorks](https://github.com/benlawraus/pyDALAnvilWorks).

When the local machine code passes the tests, run 

        ./git_push_to_anvil_works.zsh
to sync changes to the online app.

If there is new code on the online app, run

        ./git_pull_from_anvil_works.zsh
to sync the local machine to the online app.

If there are changes to the online database schema, pull the app to the local machine (using the above script) and run

        ./yaml2schema.zsh
to update the local database schema. 

Purpose
=======
This project exists in order to use [PyCharm](https://www.jetbrains.com/pycharm/) (and other IDEs?) on [anvil.works](https://anvil.works) apps. It allow you to:

* Use any local database while testing your [anvil.works](https://anvil.works) app.
* Create and run tests using pytest. These tests would be for the python in client_side forms, as well as
  server_side python. No testing of javascript UI can be done here, although it is possible to execute the
  ```self.link_clicked(**event_args)``` of form's class.
* Most importantly: use [PyCharm](https://www.jetbrains.com/pycharm/) with auto-complete and github co-pilot.


Notes
=====

Directory Structure
-------------------
- `venv`  (created by setup_project.zsh) Is the local python virtual environment.
- [anvil](https://github.com/benlawraus/anvil) (a mock of anvil module )
- [_anvil_designer](https://github.com/benlawraus/_anvil_designer) (converts form_template.yaml` into mock classes )
- `client_code`  (git-cloned from anvil.works)
- `server_code`  (git-cloned from anvil.works)
- `tests`
    - `database`  (your sqlite and pydal files to run your database on your laptop)
    - `pydal_def.py`  # generated from anvil.yaml using yaml2schema
- `tests_projects`
    - `test_00_yaml.py`  (your own pytest)
- `anvil.yaml` (git-cloned from anvil.works)
- `backup`  This is a copy of client_code and server_code that is saved here before pulling the app from [anvil.works](anvil.works).

Scripts Action
----------------
- [setup_project.zsh](setup_project.zsh)  (creates `venv`, clones submodules) Executed only once to initialize project structure.
- [yaml2schema.zsh](yaml2schema.zsh)  (converts `anvil.yaml` to `tests/pydal_def.py`, the database schema) This script needs to be run after any changes to the database schema.
- [git_push_to_anvil_works.zsh](git_push_to_anvil_works.zsh)  (pushes your changes to [anvil.works](anvil.works)) Needs to run to sync local changes to the app server.
- [git_pull_from_anvil_works.zsh](git_pull_from_anvil_works.zsh)  (pulls your changes from [anvil.works](anvil.works)) Needs to be run to sync local machine to changes on app server.
- `_anvil_designer/generate_files.py`  (converts `form_template.yaml` to mock client_code classes in `_anvil_designer.py`) Is executed from `git_pull_from_anvil_works`.
- `_anvil_designer/generate_apptable.py` (generates dummy classes in `AppTables`  from `anvil.yaml` to allow auto-complete of database tables). Is executed from `yaml2schema`.

Database
-------------------------
1. Run `./yaml2schema.zsh`
after changes to database schema of the online anvil app. Changes are reflected in `anvil.yaml` which is pulled from the online app using the script `git_pull_from_anvil_works.zsh`.
2. `anvil/tables/AppTables.py` is a mock of the table classes. It's sole purpose is for auto-complete of database tables.
3. It is possible to download the anvil.works database into the local machines's sqlite database.
A csv file would be exported from the onine app and imported into sqlite using  [pyDal](https://py4web.com/_documentation/static/en/chapter-07.html).
4. Other databases such as `postgresql` can be used. The `pydal` module is used to connect to the database. Refer to the [pyDal](https://py4web.com/_documentation/static/en/chapter-07.html) documentation for more information.  

server_code
-------------------------
The `anvil.yaml` file is used to generate the database and the `AppTable` class. The `AppTable` class is needed
to utilize auto-complete in the IDE for table names. The database and `AppTable` needs to be re-generated
after every change to the database on anvil.works otherwise local code and online code are not synced.  The sync will delete the local test
database when it is re-schemed. [yaml2schema.zsh](yaml2schema.zsh) automates this action.

(Note:`anvil/tables/AppTables.py` is generated by:

    python -m _anvil_designer.generate_apptable

included in [yaml2schema.zsh](yaml2schema.zsh).)


client_code
-------------------------
For client code tests,  `_anvil_designer.py` needs to be generated in the form directory. Every form needs one.
[_anvil_designer](https://github.com/benlawraus/_anvil_designer) generates the mock classes of the forms contained in each `_anvil_designer.py` so that useful tests can be written for client code and 
auto-complete is functioning on form components.
To generate the ``_anvil_designer.py`` files:

    python -m _anvil_designer.generate_files

This is included in [git_pull_from_anvil_works.zsh](git_pull_from_anvil_works.zsh).

In case it is needed within a test:

    from _anvil_designer.generate_files import yaml2class
    class TestYaml2Class:
        def test_init(self):
            yaml2classes()



The entire anvil docs have been converted into dummy classes and functions in the repo [anvil](https://github.com/benlawraus/anvil). If the IDE does not auto-complete,
make sure the dummy class or function has an instruction to be imported. These classes and functions are in the anvil
directory.

A form is then a child class of a Template class imported by:

    from ._anvil_designer import Form1Template

A Form __init__ would look like::

    class Form1(Form1Template):
        def __init__(self, **properties):
            # Set Form properties and Data Bindings.
            self.init_components(**properties)
            self.drop_down.items = ('up','down','sideways')

When running python on a local machin, the attributes of Form1 are initialized in the self.init_components(), so::

    self.drop_down.items = ('up','down','sideways')

has to be **AFTER** the call to init_components().



Compatibility
-------------
This project was developed and tested only on OSX with PyCharm. 
To run on other systems, the scripts need to be translated for your particular system. ChatGPT can offer a good starting point.
