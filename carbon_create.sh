#!/bin/bash

#get package name
allPath=$1
zipName=${allPath##*/}
echo $zipName
dirName=${zipName%.*}
echo $dirName
carbonPath=./$dirName/repository/components

#unzip
function unzip_package(){
    rm -rf ./$dirName
    unzip $allPath
}

#mvn package pom.xml
function package_pom(){
    mvn package -Dmaven.test.skip=true
    cp ./target/*.jar $carbonPath/dropins
}

#copy all dependence of pom to container's dropins
function cope_all_dependency(){
    mvn dependency:copy-dependencies -DoutputDirectory=$carbonPath/dropins
}

#move 3thd jar which not a osgi bundle to dir of lib
function remove_bundle(){
    mv $carbonPath/dropins/mysql-connector-java*.jar $carbonPath/lib/

    #move jar which not used in runtime or wso2 container already exists
    rm -rf $carbonPath/dropins/junit*.jar
    rm -rf $carbonPath/dropins/dom4j*.jar
    rm -rf $carbonPath/dropins/antlr*.jar
    rm -rf $carbonPath/dropins/org.apache.felix.scr.annotations*.jar
    rm -rf $carbonPath/dropins/org.wso2.carbon.logging.propfile*.jar
    rm -rf $carbonPath/dropins/commons-logging*.jar
    rm -rf $carbonPath/dropins/jta-1.1.jar
    rm -rf $carbonPath/dropins/slf4j.api_1.6.1.jar
    #rm -rf $carbonPath/dropins/org.osgi*.jar

    #move jar which not used anytime
    rm -rf $carbonPath/dropins/validation-api-1.0.0.GA.jar
    rm -rf $carbonPath/dropins/hamcrest-core-1.3.jar
    rm -rf $carbonPath/dropins/xml-apis-1.0.b2.jar
}

unzip_package
package_pom
cope_all_dependency
ls -l $carbonPath/dropins
remove_bundle
ls -l $carbonPath/dropins
