# Analytics

We use event and visit tracking to better recognize our user's needs. On the backend, we record our controllers and actions. On the client side, we track page's visited, elements clicked, and provide functions for JavaScript triggered events. Our primary tracking mechanism is based on the ```ahoy_matey``` gem. 

For more information about ```Ahoy``` go to [the repo page](https://github.com/ankane/ahoy).

## Backend

Our backend activity is tracked using a ```after_action``` filter.

```
# application_controller.rb
after_action :track_action

def track_action
  ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters
end
```

Specific events can be tracked via Ruby events using the following:

```
ahoy.track "Viewed book", title: "Hot, Flat, and Crowded"
```

## Client side

Our frontend is tracked using JavaScript. The ```ahoy.trackAll();``` function in ```application.js``` tracks page view and click activity and stores it in the ```Visit``` model.

Specific events can be tracked via JavaScript events using the following:

```
ahoy.track("Viewed book", {title: "The World is Flat"});
```

## User Association

The the ```current_user``` is automatically attached to the visit.

## Activity Association

New ```proposals```, ```reports``` and ```comments``` are generated with a ```visit_id``` column. The ```visit_id``` corresponds to the session visit associated with the model's creation. The ```visit``` can be used to observe a user's clickstream.

The visit association is done in the model using ```visitable``` and adding a UUID ```visit_id``` column.

## Visit Duration

By default, a new visit is created after 4 hours of inactivity.

## Development

Ahoy is built with developers in mind. You can run the following code in your browser’s console.

Force a new visit

```ahoy.reset(); // then reload the page```

Log messages

```ahoy.debug(); ```

Turn off logging

```ahoy.debug(false); ```

Debug endpoint requests in Ruby

```Ahoy.quiet = false```

## Admin

```Visit``` and ```Event``` data can be viewed in the ActiveAdmin panel, usnder the ```Tracking``` menu item.

![screen shot 2016-02-05 at 1 04 31 pm](https://cloud.githubusercontent.com/assets/1332366/12854594/94244b2c-cc08-11e5-8f4c-22be59ffbadc.png)

