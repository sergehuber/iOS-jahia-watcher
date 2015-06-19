# Jahia Digital Factory Tasks on Apple Watch
An example of integrating Jahia's Digital Factory tasks with the Apple Watch

## Introduction

The git repository contains the source for for an Apple Watch application that illustrates how to integrate with Jahia Digital Factory's community posts and tasks. It provides full access to the list of 20 latest posts on the watch, and allows moderation to be performed directly on the device. It also provides access to any open tasks and perform workflow steps, for example to validate the publication of a page.

## Requirements

- XCode 6.3+
- iOS 8.2+
- Jahia Digital Factory 7.0+ (http://www.jahia.com)
- Jahia RESTful API module 2.1+ (https://github.com/Jahia/jcrestapi, included in DF 7.1, but not in 7.0)
- Jahia ios-push-notifications module (https://github.com/Jahia/ios-push-notifications)
- Jahia jahia-watcher-backend module (https://github.com/Jahia/jahia-watcher-backend)
- Jahia jahia-spam-filtering module (https://github.com/Jahia/jahia-spam-filtering)

## Installation steps

1. Download the source code, configure, compile (using mvn clean install) & deploy the ios-push-notifications module into your Jahia server by following the instructions on the following page : https://github.com/Jahia/ios-push-notifications
2. Download the source, configure, compile (using mvn clean install) & deploy the jahia-spam-filtering module into your Jahia server by following the instructions on the following page : https://github.com/Jahia/jahia-spam-filtering
3. Download the source, compile and deploy the jahia-watcher-backend module. This module needs no configuration, and can simply be deployed
4. If you're using a recent version of the jcrestapi module, you will need to activate the query API by modifying your digital-factory-config/jahia/jahia.properties file to set the jahia.find.disabled=false. 
5. You can then install the compiled iOS application onto an iPhone paired with an Apple Watch.
6. Launch the app on the phone first, you will see the settings screen that will ask for the connection information to connect to the Jahia server. 
7. Once the information has been correctly entered, click save. This will trigger a connection to the server. If you get a "Login failed" error popup, this means that something is wrong while connecting to the server, either that the connection information is not correct or that the Jahia server is not reachable for another reason (firewall settings, local networks ?)
8. If the connection worked, you should see the list of latest posts that are coming from the Jahia server. If you had failures connecting you might need to force the refresh of the posts by pulling the list down to refresh it.
9. Go into the Apple Watch companion application on the phone, and make the the "Jahia Watcher" application is listed and that it is both installed and that the glance screen is also activated.
10. You should then be able to launch the app on the watch, and see the list of posts. The same is true for tasks, if there are any open tasks on the server. If not the easiest way to create one is to modify some content, and launch a publication workflow.
11. If the ios-push-notifications module is correctly configured, any new post creation or task creation should trigger a notification on both the phone and the watch. Remember that if the phone application is active, no notifications will be sent to the watch so make sure you switch away from the phone app if you want to make sure the watch gets the notifications.

