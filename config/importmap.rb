# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "leaflet", to: "https://unpkg.com/leaflet@1.9.4/dist/leaflet-src.esm.js"
pin "@rails/actioncable", to: "@rails--actioncable.js" # @8.1.300
pin "@rails/actioncable/src", to: "@rails--actioncable.js"
