import os
from jinja2 import Environment, FileSystemLoader, select_autoescape

env = Environment(
    loader=FileSystemLoader("templates"), autoescape=select_autoescape(["html", "xml"])
)  # Tell Jinja where to find stuff


class HTMLIndex:
    def __init__(self, directory):
        self.directory = directory

    def render_html(self):
        indextemplate = env.get_template("index.html")
        index = indextemplate.render()
        output = self.os_walk()
        result = index.replace("@@@", output)
        print(result)  # just catch this and write to disk

    def scandir(self):
        pass

    def os_walk(self):
        template = env.get_template("dir.html")
        output = ""
        for root, dirs, files in sorted(os.walk(self.directory)):
            if root.endswith(self.directory):
                continue
            if len(files) == 0:
                continue
            root = root.replace(f"{self.directory}/", "")
            output += template.render({"root": root, "dirs": dirs, "files": files})
        return output


def main():
    index = HTMLIndex("public")
    index.render_html()


if __name__ == "__main__":
    main()
