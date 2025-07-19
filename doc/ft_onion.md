
# Introduction

The goal of this project is to create a web page and make it accessible from the Tor net-
work by creating ahidden service. Thehidden serviceis a web service that hides
on the Tor network.

What is the Tor network?

# Mandatory Part

You must run a web server that shows a webpage on the Tor network.

- The service must have a static web page: a singleindex.htmlfile. The page will
    be accessible through a url of the typexxxxxxxxx.onion. The content displayed
    on the page isup to you.
- Nginxwill be used to configure the web server. No other server or framework is
    allowed.
- Access to the static page via HTTP on port 80 must be enabled.
- Access to the server via SSH on port 4242 must be enabled.
- You should not open any ports or set any firewall rules.

```
| Files to submit |
|---------------------|
| index.html |
| nginx.conf |
| sshd_config |
| torrc |
```
You can use anything you want in order to validate this project. It is noted that you
should be careful not to go too far.

However, you need to justify your choices and add what is needed to your repository.

Whether it is a docker image or something else.

```
If you choose to use a VM you don’t have to push it in your
repository.
```

# Bonus Part

You can enhance your project with the following features:

- SSH fortification. It will be thoroughly tested during evaluation.
- An interactive application, something more impressive than a static webpage.

```
The bonus part will only be assessed if the mandatory part is
PERFECT. Perfect means the mandatory part has been integrally done
and works without malfunctioning. If you have not passed ALL the
mandatory requirements, your bonus part will not be evaluated at all.
```
