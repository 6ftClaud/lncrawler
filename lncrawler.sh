#!/usr/bin/bash

lncrawlerhelp () {
    echo -e "Usage:\n\n"\
        "--help                     Displays help\n"\
        "--install                  Installs lncrawler\n"\
        "--uninstall                Uninstalls lncrawler\n"\
        "--latest <url>             Downloads the latest chapter\n"\
        "--first <number> <url>     Downloads the first <x> chapters\n"\
        "--last <number> <url>      Downloads the last <x> chapters\n"\
        "--all <url>                Downloads everything"
    exit
}

install () {
    docker image inspect lncrawler >/dev/null
    if [ $? == 0 ]
    then
        :
    else
        git submodule foreach git pull
        git submodule foreach git reset --hard
        pushd lightnovel-crawler >/dev/null
        echo "LABEL system.prune='do_not_delete'" >> ./scripts/Dockerfile
        docker build -t lncrawler -f ./scripts/Dockerfile .
        popd >/dev/null
    fi

    if [ -d /home/$USER/.cache/lncrawler ]
    then
        :
    else
        mkdir /home/$USER/.cache/lncrawler
        echo "Downloads are placed in /home/$USER/Downloads/ folder"
    fi

    if [ -f /home/$USER/.local/bin/lncrawler ]
    then
        :
    else
        ln -s $(pwd)/lncrawler.sh /home/$USER/.local/bin/lncrawler
        echo "You can now execute the crawler with 'lncrawler'"
    fi
    exit
}

uninstall () {
        docker image rm lncrawler
        rm -rf /home/$USER/.cache/lncrawler
        rm /home/$USER/.local/bin/lncrawler
        exit
}

case $1 in

    "")
        lncrawlerhelp;;

    "--help")
        lncrawlerhelp;;

    "--install")
        install;;

    "--uninstall")
        uninstall;;

    "--latest")
        command="--suppress --format epub -f --single --last 1 -s $2 -o /home/appuser/app/Lightnovels/";;

    "--first")
        command="--suppress --format epub -f --single --first $2 -s $3 -o /home/appuser/app/Lightnovels/";;

    "--last")
        command="--suppress --format epub -f --single --last $2 -s $3 -o /home/appuser/app/Lightnovels/";;

    "--all")
        command="--suppress --format epub -f --all -s $2 -o /home/appuser/app/Lightnovels/";;


esac

docker run --rm -v "/home/$USER/.cache/lncrawler:/home/appuser/app/Lightnovels" -it lncrawler $command

find /home/$USER/.cache/lncrawler/ -name "*.epub" -exec mv {} /home/$USER/Downloads/ \;

<<comment
optional arguments:
  -h, --help            show this help message and exit

  -v, --version         show program's version number and exit
  -l                    Set log levels. (-l = warn, -ll = info, -lll = debug).
  --list-sources        Display a list of available sources.
  --crawler [FILES ...]
                        Load additional crawler files.
  -s URL, --source URL  Profile page url of the novel.
  -q STR, --query STR   Novel query followed by list of source sites.
  -x [REGEX], --sources [REGEX]
                        Filter out the sources to search for novels.
  --login USER PASSWD   User name/email address and password for login.
  --format E [E ...]    Define which formats to output. Default: all.
  --add-source-url      Add source url at the end of each chapter.
  --single              Put everything in a single book.
  --multi               Build separate books by volumes.
  -o PATH, --output PATH
                        Path where the downloads to be stored.
  --filename NAME       Set the output file name
  --filename-only       Skip appending chapter range with file name
  -f, --force           Force replace any existing folder.
  -i, --ignore          Ignore any existing folder (do not replace).
  --all                 Download all chapters.
  --first [COUNT]       Download first few chapters (default: 10).
  --last [COUNT]        Download last few chapters (default: 10).
  --page START STOP.    The start and final chapter urls.
  --range FROM TO.      The start and final chapter indexes.
  --volumes [N ...]     The list of volume numbers to download.
  --chapters [URL ...]  A list of specific chapter urls.
  --bot {console,telegram,discord,test}
                        Select a bot. Default: console.
  --shard-id [SHARD_ID]
                        Discord bot shard id (default: 0)
  --shard-count [SHARD_COUNT]
                        Discord bot shard counts (default: 1)
  --suppress            Suppress all input prompts and use defaults.
  --close-directly      Do not prompt to close at the end for windows platforms.
  --resume [NAME/URL]   Resume download of a novel containing in /home/appuser/app/Lightnovels
comment