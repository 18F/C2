# Generating the model diagram

![model diagram](models_brief.png)

This image was created with [RailRoady](https://github.com/preston/railroady) and [Graphviz](http://www.graphviz.org). You can regenerate with:

1. Generate the graph as a DOT file.

    ```bash
    bundle exec railroady -o doc/models.dot -M -b
    ```

1. Generate the image with

    ```bash
    dot -Tpng doc/models.dot > doc/models_brief.png
    ```
