import QtQuick 2.7

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0

import "singletons" as Singletons

Item {
    id: appDb

    //--------------------------------------------------------------------------

    SqlDatabase {
        id: db
        databaseName: dataFolder.filePath(Singletons.Constants.kDatabaseName)

        onErrorChanged: {
            if (error) {
                console.log("error:", error.toString());
            }
        }
    }

    function exists() {
        if (dataFolder.fileExists(Singletons.Constants.kDatabaseName)){
            return true;
        }
        else {
            return false;
        }
    }

    //--------------------------------------------------------------------------

    function create() {
        console.log("----------------------------create")
        if ( dataFolder.makeFolder() ){
           // var dbName = Singletons.Constants.kDatabaseName
            var sqlFile = "tilepackagekreator.sql";
           // db.databaseName = dataFolder.filePath(dbName);

            if (!db.open()) {
                console.error("Error opening database:", filePath);
            }

            var sqlCommands = readSql(sqlFile);
            console.log(JSON.stringify(sqlCommands));

            var errorCount = 0;
            var successCount = 0;

            sqlCommands.forEach(function (sql) {
                sql = sql.trim();
                if (!sql.length) {
                    return;
                }

                console.log("-----------------------------------sql:", sql);

                var query = db.query(sql);

                if (query.error) {
                    console.log("Command sql:", sql);
                    console.log("Command error:", query.error.toString());
                    errorCount++;
                }
                else {
                    console.log("Command succeeded");
                    successCount++;
                }
            });

            console.log("Closing database:", db.databaseName);
            db.close();

            console.log(successCount, "commmands succeeded");
            console.log(errorCount, "commands failed");
        }
        else {
            console.log("---------------didn't make folder")
        }
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: folder

        url: "sql"
    }

    FileFolder {
        id: dataFolder
        path: Singletons.Constants.kDatabasePath
    }

    function readSql(sqlFile) {
        console.log("---------------------------------------------Reading sql:", sqlFile);

        var text = folder.readTextFile(sqlFile);

        // console.log("text:", text);

        var sqlCommands =  text.split(";");

        console.log(sqlCommands.length, " commands");

        return sqlCommands;
    }

    //--------------------------------------------------------------------------
}
