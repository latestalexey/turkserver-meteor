Package.describe({
    summary: "Online experimental framework built with Meteor"
});

Npm.depends({
    mturk: "0.4.1",
    deepmerge: "0.2.7" // For merging config parameters
});

Package.on_use(function (api) {
    // Client-only deps
    api.use([
        'bootstrap',
        'session',
        'handlebars',
        'templating'
    ], 'client');

    // Client & Server deps
    api.use([
        'accounts-base',
        'accounts-ui',
        'accounts-password', // for the admin user
        'deps',
        'stylus',
        'jquery',
        'underscore',
        'coffeescript',
        'facts'
    ]);

    // Non-core packages
    api.use('bootboxjs');
    api.use('x-editable-bootstrap');
    api.use('iron-router');
    api.use('moment');
    api.use('collection-hooks');
    api.use('user-status');

    // Shared files
    api.add_files([
        'lib/common.coffee'
    ]);

    // Server files
    api.add_files([
        'lib/config.coffee',
        'lib/turkserver.coffee',
        'lib/mturk.coffee',
        'lib/grouping.coffee',
        'lib/experiments.coffee',
        'lib/logging.coffee',
        'lib/assigners.coffee',
        'lib/connections.coffee',
        'lib/accounts_mturk.coffee',
        'lib/lobby_server.coffee'
    ], 'server');

    // Client
    api.add_files([
        'client/templates.html',
        'client/ts_client.styl',
        'client/ts_client.coffee',
        'client/grouping_client.coffee',
        'client/logging_client.coffee',
        'client/helpers.coffee',
        'client/lobby_client.html',
        'client/lobby_client.coffee',
        'client/dialogs.coffee'
    ], 'client');

    // Admin
    api.add_files([
        'admin/admin.styl',
        'admin/util.html',
        'admin/util.coffee',
        'admin/clientAdmin.html',
        'admin/clientAdmin.coffee',
        'admin/experimentAdmin.html',
        'admin/experimentAdmin.coffee',
        'admin/lobbyAdmin.html',
        'admin/lobbyAdmin.coffee'
    ], 'client');

    api.add_files('admin/admin.coffee', 'server');

    api.export(['TurkServer']);
});

Package.on_test(function (api) {
    api.use('turkserver');

    api.use([
      'accounts-base',
      'accounts-password',
      'deps',
      'coffeescript'
    ]);

    api.use('iron-router');

    api.use([
      'tinytest',
      'test-helpers'
    ]);

    api.use('session', 'client');

    api.add_files("tests/insecure_login.js");

    api.add_files('tests/utils.coffee');

    api.add_files('tests/lobby_tests.coffee');
    api.add_files('tests/auth_tests.coffee', 'server');
    api.add_files('tests/hook_tests.coffee');
    api.add_files('tests/grouping_index_tests.coffee', 'server');
    api.add_files('tests/grouping_tests.coffee');
    api.add_files('tests/experiment_tests.coffee');
    api.add_files('tests/logging_tests.coffee');
});
