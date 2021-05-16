# patterns

[![CI/CD](https://github.com/ggiuffre/patterns/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/ggiuffre/patterns/actions/workflows/build-and-test.yml)



This is the source code for _Patterns_, a mobile and web app that tracks
patterns between habits and events in your day-to-day life. In other words
_Patterns_ tells you how your day-to-day habits and events correlate with
each other, so that you can improve yourself and find what are possible causes
of a problem.

As an example you could to track the times when you work out, the quality
of your sleep, the food you eat, and events in your social life. With enough
data _Patterns_ might show that there is a correlation between workouts and you
sleeping well.



## Roadmap

I'm opening-sourcing this project at an early stage: this app is probably **not
mature enough** to give you valuable insights yet. Only boolean time series can
be tracked, and the similarity measure that is used to compare them is a bit
naive.

Here's what the roadmap looks like at the moment:

* Integrate the app with popular calendar apps, so that a user doesn't have to
  manually enter events.
* Allow to track _how_ events happen, first with a "categorical" score that
  each event can have (e.g. workouts can have an intensity that goes from 0 to
  5, instead of just happening or not happening -- which is the current
  "boolean" nature of events on the app), then with a "continuous" score.
* Add more ways to compare time series (more "similarity measures" as they're
  called in the source code) and possibly some totally different way of finding
  patterns among events.
* Allow the app to be used in a non-authenticated mode.
* Add more ways to authenticate (with authentication providers, for example).
* Add end-to-end tests, as soon as Flutter's testing framework will be more
  stable.



## Technologies involved

Patterns is a cross-platform app built with Flutter.

It relies on the following third-party Flutter libraries:

* `firebase_auth` for authentication;
* `cloud_firestore`, `flutter_riverpod` and `shared_preferences` for state
  management;
* other dependencies (see `./pubspec.yaml`)



## Developing principles

This app is being developed with these principles in mind:

* free and open-source
* platform-independent
* keep it simple (think twice before adding a dependency, write idiomatic code,
  avoid stateful computation when possible)
