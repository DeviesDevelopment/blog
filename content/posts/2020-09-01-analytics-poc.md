---
categories:
  - Implementation
date: "2020-09-01T00:00:00Z"
title: Analytics without third-party tools
---

Finding out how much traffic your site has and how your users interact with it is always crucial. Such information will enable you to scale your backend properly, fine-tune the user experience and weed out unused features. Some even go so far as claiming that data is the "gold of our time". Regardless of the truth of that claim, few can dispute the usefulness of user analytics data.

The go-to solution for most developers is to use Google Analytics (in fact used by [55% of all websites](https://w3techs.com/technologies/details/ta-googleanalytics)) or some other third party framework. Although this can surely be a valid choice and a quick way forward, using a third party tool to handle user analytics data raises some concerns. First of all, you give away data about how your product is being used for free (or perhaps you even pay for it!). And more importantly, it makes it harder for you to guarantee that potentially sensitive user data is handled in an anonymous and secure way. The best way to guarantee that your data is in safe hands is to let as few hands as possible get in touch with the data.

For the above reasons, you should at least consider implementing your own analytics tool. It turns out that it is actually much simpler than it sounds, at least as long as your use case is relatively simple (which it most probably is).

## Implementation

As a proof of concept, we implemented a quick demonstration in React. The React application that we made will gather analytics data about the very same website that is used to display the gathered data. Disclaimer: the solution we came up with is heavily inspired by [a great blog post by P.C. Maffey](https://www.pcmaffey.com/roll-your-own-analytics/).

Live demo: [http://devies-analytics-poc.s3-website-eu-west-1.amazonaws.com/](http://devies-analytics-poc.s3-website-eu-west-1.amazonaws.com/)

Source code: [https://github.com/DeviesDevelopment/analytics-poc](https://github.com/DeviesDevelopment/analytics-poc)

### Overview

The data we are interested in is to count the number of **sessions** on our website. For each session we are also interested in knowing which pages were visited, in which order and how long the user stayed on each page. A session therefore consists of a number of **events**, where every page change is considered a new event. We decided to only store non-sensitive user data, meaning no IP addresses or other data that can be used to identify the user behind a specific session. We also decided not to use any cookies in the user's browser to detect whether it's a new or returning visitor.

### How it works

Every time the path changes, an event is stored in the [Analytics.jsx](https://github.com/DeviesDevelopment/analytics-poc/blob/master/frontend/src/Analytics.jsx) component. When the browser session ends, all the collected events are sent (together with some metadata) in a single request to a lambda endpoint. The lambda then parses the data and saves it to a DynamoDB table. This means that for every user session, only a single request is sent to the analytics endpoint, making this approach very lightweight.

### Detecting path changes

To detect when the path changes, we have added a component ([Analytics.jsx](https://github.com/DeviesDevelopment/analytics-poc/blob/master/frontend/src/Analytics.jsx)) to track it on the top-level in our DOM. The component doesn't render anything, but leverages the following React hook to detect path changes:

```jsx
React.useEffect(() => {
  pushEvent({
    pathname: location.pathname,
    timestamp: Date.now(),
  });
  console.log("Location changed", location.pathname);
}, [location]);
```

The events are best stored as a simple array in the state of the component. You can also use Redux if you prefer, or store it using a [ref](https://reactjs.org/docs/refs-and-the-dom.html) in a stateless component.

### Sending data to the backend

To detect when the browser session ends, we have set up various event listeners:

```javascript
window.addEventListener("pagehide", endSession);
window.addEventListener("beforeunload", endSession);
window.addEventListener("unload", endSession);
```

The `endSession()` function in turn sends a [beacon](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/sendBeacon) with the collected data to the backend (a beacon is a request that is sent asynchronously and that will finish in the background even if the browser session is terminated).

```javascript
window.navigator.sendBeacon(url, JSON.stringify(data));
```

Some workarounds have had to be added to handle various browsers as well, see [the original post](https://www.pcmaffey.com/roll-your-own-analytics/) for more details.

### Backend

Our backend is hosted on AWS and set up using CloudFormation and AWS SAM. It is very minimal, containing only an API Gateway as interface, a DynamoDB database for storing the gathered user analytics data and two lambda functions; one for saving data and one for retrieving data. You can browse the template file [here](https://github.com/DeviesDevelopment/analytics-poc/blob/master/backend/template.yml).

## Next steps

First of all, you should consider what it is that you really want to know about how people use your product. Just collecting data for the sake of it is pretty pointless. That being said, here are some ideas for how this POC could be expanded:

- Gather other types of events other than just path changes. Such as: buttons clicked, external link opened.
- Improve UI for browsing data.
- Aggregate other kinds of metrics. See [this list on Wikipedia](https://en.wikipedia.org/wiki/Web_analytics#On-site_web_analytics_-_definitions) for some inspiration.
- Different browsers sometimes behaves very differently, so more work is needed to make sure we handle all possible combinations of devices and browsers properly.
- If you use some other implementation than React, this solution should be straightforward to reuse. Here is [an implementation in Vue](https://github.com/Sundin/armory-online/blob/master/src/components/Analytics.vue).
- Implement some check to filter out bots and scrapers, as you are probably only interested in the behaviour of real human users.

## Takeaways

User behaviour analytics can be collected anonymously without the need for any big tool or framework. The upside of this approach is that you don't need to bloat down your application with any heavy third-party dependencies, and also that you will maintain control of your users' data. The only downside is of course that you need to implement the interface for aggregating and displaying the collected data yourself.

While this proof-of-concept shows that is relatively easy to set up your own analytics infrastructure, there are probably countless number of corner cases that we did not consider. In a real-life production application, the golden middle way would therefore probably be to choose a self-hosted, open-source analytics tool instead. That way you stay in control of the data, while still not having to fix all the bugs on your own. Some of the alternatives include [Open Web Analytics](http://www.openwebanalytics.com/), [Matomo](https://matomo.org/matomo-on-premise/), [Countly](https://count.ly/community-edition) and [Plausible](https://plausible.io/self-hosted-web-analytics).

## References

- The original idea and some of the implementation taken from [this blog post](https://www.pcmaffey.com/roll-your-own-analytics/).

- The [Wikipedia article on web analytics](https://en.wikipedia.org/wiki/Web_analytics) contains much background information about this topic.

By Gustav Sundin & Rickard Andersson
