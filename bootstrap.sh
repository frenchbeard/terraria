#! /bin/bash

# Default environment, or provided by the running configuration
WORLD_FILENAME=${WORLD_FILENAME:-"None provided"}
TERRARIA_ROOT=${TERRARIA_ROOT:-"/home/terraria"}
TERRARIA_CONFIGPATH=${TERRARIA_CONFIGPATH:-"$TERRARIA_ROOT/Worlds"}
TERRARIA_LOGPATH=${TERRARIA_LOGPATH:-"$TERRARIA_ROOT/logs"}
TERRARIA_PLUGINPATH=${TERRARIA_PLUGINPATH:-"$TERRARIA_ROOT/plugins"}
WORLD_PATH="$TERRARIA_ROOT/$WORLD_FILENAME"

echo -e "\nBootstrap:\nworld_file_name=$WORLD_FILENAME\nconfigpath=$TERRARIA_CONFIGPATH\nlogpath=$TERRARIA_LOGPATH\n"
echo "Copying plugins..."
cp -Rfv "$TERRARIA_PLUGINPATH"/* ./ServerPlugins


if [ "$WORLD_FILENAME" == "None provided" ]; then
  echo "No world file specified in environment variable WORLD_FILENAME."
  if [ -z "$*" ]; then
    echo "Running server setup..."
  else
    echo "Running server with command flags: $*"
  fi
  mono --server --gc=sgen -O=all TerrariaServer.exe \
      -configpath "$TERRARIA_CONFIGPATH" \
      -logpath "$TERRARIA_LOGPATH" "$@"
else
  echo "Environment WORLD_FILENAME specified"
  if [ -f "$WORLD_PATH" ]; then
    echo "Loading world $WORLD_FILENAME..."
    mono --server --gc=sgen -O=all TerrariaServer.exe \
        -configpath "$TERRARIA_CONFIGPATH" \
        -logpath "$TERRARIA_LOGPATH" \
        -world "$WORLD_PATH" "$@"
  else
    echo -e "Unable to locate $WORLD_PATH.\nPlease make sure your world file is volumed into docker: -v <path_to_world_file>:/root/.local/share/Terraria/Worlds"
    exit 1
  fi
fi
