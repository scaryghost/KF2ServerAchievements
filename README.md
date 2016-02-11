KF2ServerAchievement provides a framework to create custom achievements for Killing Floor 2.  It is a port of the ServerAchievements 
mutator from the first Killing Floor game.  To see this README in its formatted version, checkout the project's homepage on GitHub:

https://github.com/scaryghost/KF2ServerAchievements

# Compiling the Code
Though the project name is **KF2ServerAchievements**, the code operates with the assumption that the package name is 
**ServerAchievements**, same as the original.  When adding this mutator to your *KFGame\Src* folder, make sure to rename the folder to 
ServerAchievements.  If cloning the project with Git, you can set the destination to have a different name from the project.

```git
git clone https://github.com/scaryghost/KF2ServerAchievements.git ServerAchievements
```

# Configuring the Mutator
Mutator configuration is stored in the **KFServerAchievements.ini** file.  Server owners can set what achievement packs to load and how 
to manage achievement progress.  Running the mutator once will create the ini file for you.

```ini
[ServerAchievements.SAmutator]
achievementPackClassnames=ServerAchievements.TestStandardAchievementPack
dataSourceClassname=ServerAchievements.FileDataSource
```

## Loading Achievement Packs
Achievement packs are set with the **achievementPackClassnames** array.  This variable can be copied several times to accomodate as 
many achievement packs as desired.

```ini
# Will load three achievement packs for the game
achievementPackClassnames=MyAchievements.FailPack
achievementPackClassnames=MyAchievements.FunPack
achievementPackClassnames=MyAchievements.StockKFPack
```

Users can create their own achievement packs by extending the StandardAchievementPack class.  Documentation on how the class is still 
in progress.  In the meantime, check out the TestStandardAchievementPack class for an example on how to create custom achievements.

## Saving Achievement Progress
Managing achievement progress is done with the DataSource abstract class.  The ServerAchievements package comes with two implementations 
of the abstract class, providing progress management with an ini file (FileDataSource) or a remote server (HttpDataSource).  You can 
configure which data source to use with the **dataSourceClassname** variable in the ini file.  If the dataSourceClassname variable is 
not set, the mutator will default to using the FileDataSource implementation.

```ini
dataSourceClassname=ServerAchievements.HttpDataSource
```

If neither of the pre-canned solutions are suitable for your servers, you can create your own data source by implementing the DataSource 
abstract class.

### File Data Source
The FileDataSource class saves achievement data to the **KFServerAchievementsState.ini** file, located in the config folder.  As 
mentioned above, this is the default data source unless you specify otherwise.

### Http Data Source
As the name suggest, the HttpDataSource class uses the HTTP protocol to communicate with a remote database.  You can configure the 
hostname of the remote server by setting the **httpHostname** variable.

```ini
# Use http://192.168.0.201:8000 as my remote data server
[ServerAchievements.HttpDataSource]
httpHostname=192.168.0.201:8000
```

You will need an HTTP server to handle data requests for this data source.

# Progress Menu
A custom menu is available for clients to view achievement progress in game.  Simply bind a key to the command *toggleAchievementMenu* 
to open and close the menu.  The following example sets F4 to toggle the menu:

```
SetBind F4 toggleAchievementMenu
```

The menu is built using the mobile versions of the GUI classes.  While most functionality is the same as a standard PC gui, the scroll 
list must be used as if you were using your finger to navigate on a phone.  To scroll up or down, you must hold the mouse down over the 
achievements list and move the mouse up or down to move the list accordingly.
