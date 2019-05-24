from hello_world import make_app

# uwsgi requires a global variable here
app = make_app()

if __name__ == '__main__':
    app.run()
