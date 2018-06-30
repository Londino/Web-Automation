#!/usr/bin/env rspec
require "watir"
require "rspec"
require "pry"
require "net/ssh"
require "./methods.rb"

UPASSWD = SecureRandom.base64
HOMEPAGE = 'https://example.org/'
TIME = Time.now - (6*30*24*60*60)
MONTH = TIME.ctime.split[1].upcase
YEAR = TIME.ctime.split[-1]
TRIANGLE_WEST = %w(ui-icon ui-icon-circle-triangle-w)
TRIANGLE_EAST = %w(ui-icon ui-icon-circle-triangle-e)
Email = "foobar@foo.gr"
Uname = "barfoo"
Passwd = "somekindofpassword"
Vessel_name = (0...6).map { ('a'..'z').to_a[rand(26)] }.join
#removed = "http://10.0.0.242/

describe 'Data Manager Regression Test' do
  before :all do
    launch
  end
  describe 'Functionality' do
    describe 'Step 1: Login page (empty username & password)' do
      it "should dipslay a message that you must enter a username" do
        required('username')
      end
    end
    describe 'Step 2: Login page (empty password)' do
      it "should display a message that you must enter a password" do
        required('password')
      end
    end
    describe 'Step 3: Login page (username that does not exist)' do
      it "should display recaptcha" do
        user_login('foobar','fO0b@r')
        expect(@browser.iframe.text.include?"I'm not a robot").to be true
        recaptcha("Please click anywhere in the browser window
except within the captcha frame.")
      end
    end
    describe 'Step 4: Login page (correct username; wrong password)' do
      it "should display a message that you must enter username & password" do
        user_login('#removed','foobar')
        expect(@browser.text.include?'valid username and password').to be true
        recaptcha("Please click anywhere in the browser window
except within the captcha frame.")
      end
      it "should display recaptcha after 3 failed login attempts" do
        3.times do
          user_login('#removed','foobar')
        end
        expect(@browser.iframe.text.include?"I'm not a robot").to be true
      end
    end
    describe 'Step 5: Login page; correct username & password; admin' do
      it "should redirect you to the 2fa page" do
        until @browser.url.include?'verify'
          @browser.text_field(name: 'username').set(Uname)
          @browser.text_field(name: 'password').set(Passwd)
          recaptcha("Please solve the captcha to continue.")
          @browser.button(value: 'Log in').click
        end
        expect(@browser.url.include?'verify').to be true
      end
    end
    describe 'Step 6: 2fa (wrong code)' do
      it "should redirect you to the login page" do
        @browser.text_field(name: 'twofasecret').set rand(999999)
        @browser.button(value: 'verify').click
        expect(@browser.text.include? 'Login').to be true
      end
    end
    describe 'Step 7: 2fa page accessible without credentials?' do
      it "should be redirected to login page" do
        @browser.goto HOMEPAGE + 'auth/login/verify'
        expect(@browser.text.include? 'Login').to be true
      end
    end
    describe 'Step 8: 2fa (correct code)' do
      it "should be redirected to the home page" do
        admin_login
        expect(@browser.text.include?'Dashboard').to be true
      end
    end
    describe 'Step 9: Satellite Terminals Availability; correct vessel' do
      it "should display the selected vessel's availability" do
        @browser.span(class: 'nav-label', text: 'Dashboards').click
        @browser.ul(class: %w(nav nav-second-level collapse in)).
          a(text: "Satellite Terminals").click
        @browser.ul(class: %w(nav nav-third-level collapse in)).
          a(text: "Availability").click
        if @browser.select(id: "company_select_id").text == "--- all ---"
          @browser.select(id: "company_select_id").click
          @browser.select(id: "company_select_id").option(value: "97").click
        end
        @browser.div(class: "config-align-vessels").a.click
        @browser.div(text: MONTH).click
        @browser.a(class: %w(btn btn-default buttons-collection
          buttons-page-length)).click
        @browser.ul(class: %w(dt-button-collection dropdown-menu)).
          li(index: 3).click
        expect((@browser.text.include? TIME.to_s.split[0]) &&
          (@browser.canvas(id: "dataTerminalAvailabilityChartPerDay").
          present?)).to be true
      end
    end
    describe 'Step 10: Satellite Terminals Availability; wrong vessel' do
      it "should display 'Error 404'" do
        error_404
      end
    end
    describe 'Step 11: Satellite Terminals Traffic; month' do
      it "should display the selected month's traffic" do
        @browser.ul(class: %w(nav nav-third-level collapse in)).
          a(text: "Traffic").click
        @browser.button(id: "list-#removed-pins").click
        @browser.div(text: MONTH).click
        $month = MONTH.capitalize
        expect((@browser.text.include? 'Vessels Terminals traffic') &&
          (@browser.text.include? "#{$month} #{YEAR}")).to be true
      end
    end
    describe 'Step 12: Satellite Terminals Traffic; correct vessel' do
      it "should display the selected vessel's traffic" do
        $vessel = @browser.table.tr(index: 2).td(index: 1).text
        @browser.table.tr(index: 2).td(index: 1).a.click
        expect((@browser.text.include? $vessel) &&
          (@browser.text.include? "#{$month} #{YEAR}")).to be true
      end
    end
    describe 'Step 13: Satellite Terminals Traffic; wrong vessel' do
      it "should display 'Error 404'" do
        error_404
      end
    end
    describe 'Step 14: Satellite Terminals Traffic; correct vessel; day' do
      it "should display the selected day's traffic" do
        date = @browser.table.tr(index: 5).td.a.text
        date = date.split("-")
        @browser.table.tr(index: 5).td.a.click
        expect(@browser.text.
          include? "#{$vessel}-#{$month} #{date[2]}, #{YEAR}").to be true
      end
    end
    describe 'Step 15: Satellite Terminals Traffic; day; wrong vessel' do
      it "should display 'Error 404'" do
        error_404
      end
    end
    describe 'Step 16: Satellite Per Terminal Traffic; month; correct vessel' do
      it "should display the selected vessel's monthly traffic per terminal" do
        @browser.button(class: %w(btn btn-w-m btn-primary pull-right)).click
        expect((@browser.text.include? $vessel) &&
          (@browser.text.include? "#{$month} #{YEAR}") &&
          (@browser.text.include? "Primary") &&
          (@browser.text.include? "Secondary")).to be true
      end
    end
    describe 'Step 17: Satellite Per Terminal Traffic; month; wrong vessel' do
      it "should display 'Error 404'" do
        error_404
      end
    end
    describe "Step 18: Satellite Per Terminal Traffic; correct vessel; Mb" do
      it "should display the selected vessel's monthly traffic in Mb" do
        @browser.li(class: "breadcrumb-links").a.click
        @browser.table.tr(index: 2).td(index: 2).a.click
        expect(@browser.text.include? "Terminals traffic Mb").to be true
      end
    end
    describe "Step 19: Satellite Per Terminal Traffic; correct vessel; %" do
      it "should display the selected vessel's monthly traffic by percentage" do
        @browser.back
        @browser.table.tr(index: 2).td(index: 2).a(index: 1).click
        expect(@browser.text.include? "#{$vessel} Percentage").to be true
      end
    end
    describe 'Step 20: Massive Alerts; Com Loss; Admin' do
      describe 'Create'do
        it "should redirect to Vessel's Massive Alerts Com Loss page" do
          @browser.span(class: 'nav-label', text: 'Services').click
          @browser.ul(class: %w(nav nav-second-level collapse in)).
            a(text: "Alerts").click
          sleep(1)
          @browser.ul(class: %w(nav nav-second-level collapse in)).
            ul(class: %w(nav nav-third-level collapse in)).
            a(text: "Massive Alerts").click
          @browser.ul(class: %w(nav nav-fourth-level collapse in)).
            a(text: "Com Loss").click
          @browser.button(id: "create-comloss-massive-alert").click
          @browser.text_field.set "AFRO"
          @browser.send_keys :enter
          @browser.text_field(id: "input-targetmail").set Email
          @browser.text_field(id: "input-threshold").set "5"
          @browser.text_field(id: "input-secthreshold").set "10"
          @browser.send_keys :tab
          6.times {@browser.span(class: TRIANGLE_WEST).click}
          @browser.table(class: 'ui-datepicker-calendar').
            tr(index: 3).td(index: 3).click
          sleep(1)
          $start_date = @browser.text_field(id: "input-starttime").value
          @browser.button(value: "Create").click
          expect(@browser.text.include? $start_date).to be true
        end
      end
      describe 'Enable/Disable/Remove Alerts' do
        it "should enable/disable/remove the vessel's alerts" do
          @browser.table(id: "comloss-massive-alert-table").tr(index: -1).
            td(index: -1).checkbox.click
          @browser.button(id: "toggle-comloss-massive-alert").click
          sleep(1)
          @browser.button(id: "btn-comloss-massive-alert-toggle-modal").click
          sleep(1)
          expect(@browser.table(id: "comloss-massive-alert-table").
            tr(index: -1).td(index: 8).text == "true").to be false
          @browser.table(id: "comloss-massive-alert-table").tr(index: -1).
            td(index: -1).checkbox.click
          @browser.button(id: "delete-comloss-massive-alert").click
          sleep(1)
          @browser.button(id: "btn-comloss-massive-alert-delete-modal").click
          sleep(1)
          expect(@browser.text.include? $start_date).to be false
        end
      end
      describe 'Help' do
        it "should display the help modal" do
          help_modal("Com Loss Notification Help")
        end
      end
    end
    describe 'Step 21: Massive Alerts; Node Offline; admin' do
      describe 'Create'do
        it "should redirect to Vessel's Node Offline page" do
          @browser.ul(class: %w(nav nav-fourth-level  collapse in)).
            a(text: "Node Offline").click
          @browser.button(id: "create-nodeloss-massive-alert").click
          @browser.ul(class: 'select2-selection__rendered').click
          @browser.li(class: "select2-results__option", index: rand(52)).click
          @browser.text_field(id: "input-targetmail").set Email
          @browser.text_field(id: "input-starttime").click
          6.times {@browser.span(class: TRIANGLE_WEST).click}
          @browser.table(class: 'ui-datepicker-calendar').
          tr(index: 3).td(index: 3).click
          sleep(1)
          $start_date = @browser.text_field(id: "input-starttime").value
          @browser.button(value: "Create").click
          expect(@browser.text.include? $start_date).to be true
        end
      end
      describe 'Enable/Disable/Remove Alerts' do
        it "should reset/enable/disable the vessel's alerts'" do
          en_dis_rem_massalerts("nodeloss")
        end
      end
      describe 'Help' do
        it "should display the help modal" do
          help_modal("Node Offline Notification Help")
        end
      end
    end
    describe 'Step 22: Massive Alerts; CPU; admin' do
      describe 'Create'do
        it "should redirect to Vessel's CPU page" do
          @browser.ul(class: %w(nav nav-fourth-level  collapse in)).
            a(text: "CPU").click
          @browser.button(id: "create-cpu-massive-alert").click
          @browser.ul(class: 'select2-selection__rendered').click
          @browser.li(class: "select2-results__option", index: rand(52)).click
          @browser.text_field(id: "input-targetmail").set Email
          @browser.text_field(id: "input-threshold").set "30"
          @browser.text_field(id: "input-starttime").click
          6.times {@browser.span(class: TRIANGLE_WEST).click}
          @browser.table(class: 'ui-datepicker-calendar').
            tr(index: 3).td(index: 3).click
          sleep(1)
          $start_date = @browser.text_field(id: "input-starttime").value
          @browser.button(value: "Create").click
          expect(@browser.text.include? $start_date).to be true
        end
      end
      describe 'Enable/Disable/Remove Alerts' do
        it "should enable/disable the vessel's alerts" do
          en_dis_rem_massalerts("cpu")
        end
      end
      describe 'Help' do
        it "should display the help modal" do
          help_modal("CPU Alerts Help")
        end
      end
    end
    describe 'Step 23: Massive Alerts; RAM; admin' do
      describe 'Create/Edit'do
        it "should redirect to Vessel's RAM page" do
          @browser.ul(class: %w(nav nav-fourth-level  collapse in)).
            a(text: "RAM").click
          @browser.button(id: "create-ram-massive-alert").click
          @browser.ul(class: 'select2-selection__rendered').click
          @browser.li(class: "select2-results__option", index: rand(52)).click
          @browser.text_field(id: "input-targetmail").set Email
          @browser.text_field(id: "input-threshold").set "30"
          @browser.text_field(id: "input-starttime").click
          6.times {@browser.span(class: TRIANGLE_WEST).click}
          @browser.table(class: 'ui-datepicker-calendar').
            tr(index: 3).td(index: 3).click
          sleep(1)
          $start_date = @browser.text_field(id: "input-starttime").value
          @browser.button(value: "Create").click
          expect(@browser.text.include? $start_date).to be true
        end
      end
      describe 'Enable/Disable Alerts' do
        it "should enable/disable the vessel's alerts" do
          en_dis_rem_massalerts("ram")
        end
      end
      describe 'Help' do
        it "should display the help modal" do
          help_modal("RAM Alerts Help")
        end
      end
    end
    describe 'Step 24: Massive Alerts; Disk; admin' do
      describe 'Create/Edit'do
        it "should redirect to Vessel's Disk page" do
          @browser.ul(class: %w(nav nav-fourth-level  collapse in)).
            a(text: "Disk").click
          @browser.button(id: "create-disk-massive-alert").click
          @browser.ul(class: 'select2-selection__rendered').click
          @browser.li(class: "select2-results__option", index: rand(52)).click
          @browser.text_field(id: "input-targetmail").set Email
          @browser.text_field(id: "input-threshold").set "30"
          @browser.text_field(id: "input-starttime").click
          6.times {@browser.span(class: TRIANGLE_WEST).click}
          @browser.table(class: 'ui-datepicker-calendar').
          tr(index: 3).td(index: 3).click
          sleep(1)
          $start_date = @browser.text_field(id: "input-starttime").value
          @browser.button(value: "Create").click
          expect(@browser.text.include? $start_date).to be true
        end
      end
      describe 'Enable/Disable Alerts' do
        it "should enable/disable the vessel's alerts" do
          en_dis_rem_massalerts("disk")
        end
      end
      describe 'Help' do
        it "should display the help modal" do
          help_modal("DISK Alerts Help")
        end
      end
    end
  end
  describe 'Services; E-mail' do
    describe 'Step 25: Global Configuration; Cloud Server; admin' do
      it "should redirect to Cloud Server page" do
        @browser.ul(class: %w(nav nav-second-level collapse in)).
          a(text: "E-mail").click
        @browser.ul(class: %w(nav nav-third-level collapse in)).
          a(text: "Global configuration").click
        @browser.ul(class: %w(nav nav-third-level collapse in)).
          a(text: "Cloud server").click
        @browser.button(text: "edit").click
        @browser.text_field(id: "input-incoming-poll-timeout").set "10"
        @browser.text_field(id: "input-incoming-poll-interval").set "5"
        @browser.text_field(id: "input-incoming-size-limit").set "3"
        @browser.button(text: "save").click
        expect(@browser.text.include? "Edit Cloud Server").to be false
      end
      it "should display 'Saved OK'" do
        unless @browser.text.include? "Saving..."
          @browser.button(id: "email-mx-apply").click
          sleep(1)
          @browser.button(id: "btnApplyEmailMxYes").click
          sleep(1)
          @browser.button(text: "OK").click
          Watir::Wait.until(timeout: 120) {(@browser.text.include? "Saved OK")}
          expect(@browser.text.include? "Saved OK").to be true
        end
      end
    end
    describe 'Step 26: Global Configuration; Domain profiles; admin' do
      it "should redirect to Domain Profiles page" do
        @browser.ul(class: %w(nav nav-third-level collapse in)).
          a(text: "Domain profiles").click
        @browser.button(text: "create").click
        @browser.text_field(id: "input-name").set "yahoo.com"
        @browser.text_field(id: "input-incoming-server").set "imap.yahoo.com"
        @browser.text_field(id: "input-incoming-port").set "993"
        @browser.text_field(id: "input-incoming-protocol").set "imap"
        @browser.text_field(id: "input-incoming-ssl").set "1"
        @browser.text_field(id: "input-outgoing-server").set "smtp.yahoo.com"
        @browser.text_field(id: "input-outgoing-port").set "587"
        @browser.button(text: "save").click
        expect(@browser.text.include? "Edit Domain profile").to be false
      end
      it "should remove the Domain Profile" do
        name = @browser.table.tr(index: -1).td(index: 1).text
        @browser.table.tr(index: -1).td(index: -1).click
        sleep(1)
        @browser.button(id: "btnRemoveEmailProfileYes").click
        sleep(1)
        expect(@browser.text.include? name).to be false
      end
    end
    describe 'Step 27: Com Loss; Admin' do
      describe 'Create/Edit'do
        it "should redirect to Vessel's Com Loss page" do
          @browser.ul(class: %w(nav nav-second-level collapse in)).
            a(text: "Alerts").click
          @browser.ul(class: %w(nav nav-third-level collapse in)).
            a(text: "Com Loss").click
          @browser.div(class: "config-align-vessels").a.click
          create_edit("comloss")
          @browser.text_field(id: "input-targetmail").set Email
          @browser.text_field(id: "input-threshold").set "5"
          @browser.text_field(id: "input-secthreshold").set "10"
          @browser.send_keys :tab
          6.times {@browser.span(class: TRIANGLE_WEST).click}
          @browser.table(class: 'ui-datepicker-calendar').
            tr(index: 3).td(index: 3).click
          sleep(1)
          $start_date = @browser.text_field(id: "input-starttime").value
          @browser.button(value: "Create").click
          expect(@browser.text.include? $start_date).to be true
        end
      end
      describe 'Reset/Enable/Disable Alerts' do
        it "should reset/enable/disable the vessel's alerts" do
          @browser.button(id: "reset-comloss-alert").click
          sleep(1)
          @browser.button(id: "btn-comloss-alert-reset-modal").click
          sleep(1)
          expect(@browser.text.include? $start_date).to be false
          en_dis_alerts("comloss")
        end
      end
      describe 'Help' do
        it "should display the help modal" do
          help_modal("Com Loss Notification Help")
        end
      end
    end
    describe 'Step 28: Node Offline; admin' do
      describe 'Create/Edit'do
        it "should redirect to Vessel's Node Offline page" do
          @browser.ul(class: %w(nav nav-third-level collapse in)).
            a(text: "Node Offline").click
          create_edit("nodeloss")
          @browser.text_field(id: "input-targetmail").set Email
          @browser.send_keys :tab
          6.times {@browser.span(class: TRIANGLE_WEST).click}
          @browser.table(class: 'ui-datepicker-calendar').
            tr(index: 3).td(index: 3).click
          sleep(1)
          $start_date = @browser.text_field(id: "input-starttime").value
          @browser.button(value: "Create").click
          expect(@browser.text.include? $start_date).to be true
        end
      end
      describe 'Reset/Enable/Disable Alerts' do
        it "should reset/enable/disable the vessel's alerts" do
          @browser.button(id: "reset-nodeloss-alert").click
          sleep(1)
          @browser.button(id: "btn-nodeloss-alert-reset-modal").click
          sleep(1)
          expect(@browser.text.include? $start_date).to be false
          en_dis_alerts("nodeloss")
        end
      end
      describe 'Help' do
        it "should display the help modal" do
          help_modal("Node Offline Notification Help")
        end
      end
    end
    describe 'Step 29: CPU; admin' do
      describe 'Create/Edit'do
        it "should redirect to Vessel's CPU page" do
          @browser.ul(class: %w(nav nav-third-level collapse in)).
            a(text: "CPU").click
          create_edit("cpu")
          alert_settings
        end
      end
      describe 'Enable/Disable Alerts' do
        it "should enable/disable the vessel's alerts" do
          en_dis_alerts("cpu")
        end
      end
      describe 'Help' do
        it "should display the help modal" do
          help_modal("CPU Notification Help")
        end
      end
    end
    describe 'Step 30: RAM; admin' do
      describe 'Create/Edit'do
        it "should redirect to Vessel's RAM page" do
          @browser.ul(class: %w(nav nav-third-level collapse in)).
            a(text: "RAM").click
          create_edit("ram")
          alert_settings
        end
      end
      describe 'Enable/Disable Alerts' do
        it "should enable/disable the vessel's alerts" do
          en_dis_alerts("ram")
        end
      end
      describe 'Help' do
        it "should display the help modal" do
          help_modal("RAM Notification Help")
        end
      end
    end
    describe 'Step 31: Disk; admin' do
      describe 'Create/Edit'do
        it "should redirect to Vessel's Disk page" do
          @browser.ul(class: %w(nav nav-third-level collapse in)).
            a(text: "Disk").click
          create_edit("disk")
          alert_settings
        end
      end
      describe 'Enable/Disable Alerts' do
        it "should enable/disable the vessel's alerts" do
          en_dis_alerts("disk")
        end
      end
      describe 'Help' do
        it "should display the help modal" do
          help_modal("Disk Notification Help")
        end
      end
    end
    describe 'Step 32: Hotspot; correct vessel' do
      it "should display 'Hotspot not accessible'" do
        @browser.ul(class: %w(nav nav-second-level collapse in)).
          a(text: "Hotspot").click
        sleep(1)
        @browser.ul(class: %w(nav nav-third-level collapse in)).
          a(text: "Pins").click
        @browser.button(visible_text: "Check").click
        Watir::Wait.until(timeout: 120) {(@browser.text.include? "Fail")}
        @browser.button(visible_text: "OK").click
        sleep(1)
        expect(@browser.text.include? "not available").to be true
      end
      it "should display 'Hotspot accessible'" do
        @browser.select(id: "company_select_id").option(value: "158").click
        @browser.div(id: "company-id-158").a(text: "#removed").click
        @browser.button(visible_text: "Check").click
        Watir::Wait.until(timeout: 120) {(@browser.text.include? "Success")}
        @browser.button(visible_text: "OK").click
        sleep(1)
        expect(@browser.text.include? "History").to be true
      end
      it "should list the pins" do
        @browser.button(id: "list-#removed-pins").click
        expect(@browser.text.include? "Pins Index").to be true
      end
      it "should redirect to pins list" do
        @browser.button(id: "create-enabled").click
        @browser.select_list(name: "Time").option(value: "36000").click
        @browser.select_list(name: "Traffic Limit").
          option(value: "52428800").click
        @browser.button(id: "save-list-pins").click
        expect(@browser.text.include? "Pins Index").to be true
        Watir::Wait.until(timeout: 120) {(@browser.text.include? "Saved OK")}
      end
      it "should throttle crew" do
        @browser.button(visible_text: "Throttle Crew").click
        @browser.select_list(name: "Rate Limit").option(value: "92K/92K").click
        @browser.button(id: "save-list-pins").click
        expect(@browser.text.include? "enabled: 92K/92K").to be true
        @browser.execute_script("window.open('#{#removed}')")
        @browser.window(title: "#removed").use do
          @browser.text_field(id: "name").set "foobar"
          @browser.text_field(id: "password").set "somekindofpassword"
          @browser.a.click
          expect(@browser.table(class: "table").tr(index: 1).td(index: -2).
            text.include? "92K/92K").to be true
          @browser.window.close
        end
      end
      it "should disable pins" do
        @browser.checkbox.click
        sleep(2)
        @browser.button(visible_text: "Disable").click
        sleep(1)
        @browser.button(id: "btnDisablePinsUser").click
        sleep(2)
        Watir::Wait.until(timeout: 120) {(@browser.text.include? "Saved OK")}
        expect(@browser.table.text.include? "true").to be true
      end
      it "should enable pins" do
        @browser.checkbox.click
        @browser.button(visible_text: "Enable").click
        sleep(1)
        @browser.button(id: "btnEnablePinsUser").click
        sleep(1)
        Watir::Wait.until(timeout: 120) {(@browser.text.include? "Saved OK")}
        expect(@browser.table.text.include? "true").to be false
      end
      it "should remove pins" do
        pin = @browser.table.tr(index: -1).text
        @browser.checkbox(index: -1).click
        @browser.button(visible_text: "[ remove ]").click
        sleep(1)
        @browser.button(id: "btnDeletePinsUser").click
        sleep(1)
        Watir::Wait.until(timeout: 120) {(@browser.text.include? "Saved OK")}
        expect(@browser.table.text.include? pin).to be false
      end
      it "should display pins history" do
        @browser.button(visible_text: "History of Pins").click
        expect(@browser.text.include? "History of Pins").to be true
      end
    end
    describe 'Step 33: Hotspot; wrong vessel' do
      it "should diplay the user's company vessels" do
        wrong_vessel("Star Bulk")
      end
      it "enable/disable/remove should be unavailable" do
        expect((@browser.button(visible_text: "Enable").present?) &&
          (@browser.button(visible_text: "Disable").present?) &&
          (@browser.button(visible_text: "[ remove ]").present?)).to be false
      end
    end
    describe 'Step 34: Speedtest; correct vessel' do
      it "should display 'Saved OK'" do
        @browser.ul(class: %w(nav nav-second-level collapse in)).
          a(text: "Speedtest").click
        @browser.div(id: "company-id-158").a(text: "#removed").click
        if @browser.checkbox.checked? == true
          expect(@browser.text.include? "Saved OK").to be true
        else
        @browser.checkbox.click
        @browser.send_keys :tab
        3.times {@browser.span(class: TRIANGLE_EAST).click}
        @browser.table(class: 'ui-datepicker-calendar').
          tr(index: 3).td(index: 3).click
        @browser.div(class: "ui-timepicker-div").a.click
        12.times {@browser.send_keys :arrow_right}
        @browser.div(class: "ui-timepicker-div").a(index: 1).click
        30.times {@browser.send_keys :arrow_right}
        @browser.button(visible_text: "Done").click
        @browser.element(text: "Save").click
        sleep(1)
        @browser.div(class: "modal-footer").button.click
        Watir::Wait.until(timeout: 120) {(@browser.text.include? "Saved OK")}
        expect(@browser.text.include? "Saved OK").to be true
        end
      end
    end
    describe 'Step 35: Speedtest; wrong vessel' do
      it "should display the user's company vessels" do
        wrong_vessel("foobar")
      end
    end
    describe 'Step 36: Diagnostics; Fleet Inventory; admin' do
      it "should list/view/help/edit" do
        @browser.span(class: 'nav-label', text: 'Diagnostics').click
        sleep(1)
        @browser.ul(class: %w(nav nav-second-level collapse in)).a.click
        expect(@browser.table(id: "vessel_information").present?).to be true
        @browser.table.td.click
        sleep(1)
        expect(@browser.div(id: "more-information-vessel-115").
          present?).to be true
        @browser.button(visible_text: "OK").click
        sleep(1)
        help_modal("Vessel information help")
        @browser.button(value: "edit").click
        expect(@browser.text.include? "Edit Vessel Information").to be true
        @browser.a(visible_text: "Cancel").click
      end
    end
    describe 'Step 37: Admin; Vessels; admin' do
      it "should add Vessel" do
        @browser.span(class: 'nav-label', text: 'Admin').click
        sleep(1)
        @browser.ul(class: %w(nav nav-second-level collapse in)).
          a(text: "Vessels").click
        @browser.button(value: "Add Vessel").click
        sleep(1)
        @browser.table.tr(index: -1).a(index: 0).click
        @browser.text_field(class: %w(form-control input-mini)).set rand(9999)
        @browser.div(class: "editable-buttons").button.click
        $vessel_id = @browser.table.tr(index: -1).a(index: 0).text
        @browser.table.tr(index: -1).a(index: 1).click
        @browser.text_field(class: %w(form-control input-sm)).set imo_number
        @browser.div(class: "editable-buttons").button.click
        @browser.table.tr(index: -1).a(index: 2).click
        @browser.text_field(class: %w(form-control input-sm)).set Vessel_name
        @browser.div(class: "editable-buttons").button.click
        @browser.table.tr(index: -1).a(index: -1).click
        @browser.select_list(class: %w(form-control input-sm)).
          option(value: "4").click
        @browser.div(class: "editable-buttons").button.click
        @browser.button(value: "Save").click
        Watir::Wait.until(timeout: 120) {(@browser.text.include? "Vessels info")}
        @browser.button(id: "btnReminderConfig").click
        sleep(1)
        expect(@browser.text.include? $vessel_id).to be true
      end
    end
    describe "Step 38: Admin; Config; admin" do
      it "should create network & terminal cfg files" do
        @browser.ul(class: %w(nav nav-second-level collapse in)).
          a(text: "Config").click
#Implicit wait time of 20 secs in order to give the DM time to fetch/load
#the default network & terminal configuration values.
        sleep(20)
        @browser.div(id: "company-id-158").a(text: Vessel_name).click
#Refreshes the browser every 20 secs until the default network & terminal
#configuration values get loaded.
        until @browser.text.include? "192.168.0.251"
          sleep(20)
          @browser.refresh
        end
        @browser.div(id: "tabs-container").li(index: 1).click
        sleep(1)
        terminal_id = @browser.table(id: "term_primary").tr(index: 1).td.text
        @browser.table(id: "term_crew").td.a.click
        @browser.select_list(class: %w(form-control input-sm)).
          option(value: terminal_id).click
        @browser.send_keys :enter
        @browser.button(visible_text: "save").click
        sleep(1)
        @browser.button(id: "btnNetTermYes").click
        Watir::Wait.until(timeout: 120) {(@browser.button(index: 2).
          present? == false)}
#Parses and then pings the current url in order to extract the IP address
#of the local DM test server (usually 10.0.0.47).
        url = @browser.url.match /\/\/[a-z0-9]*.[a-z0-9]*.[a-z0-9]*.[0-9]*/
        domain = url.to_s.split("/")[-1]
        ip = `ping -c1 #{domain}`.split("\n")[0].
          match /[0-9]*[.][0-9]*[.][0-9]*[.][0-9]*/
        @govess = "cd /home/companies/158/vessels/#{$vessel_id}/"
        @cat = "ls #{@govess}out/admin/vessel/slash/opt/comix/config"
#Establishes SSH connection to the IP address fetched from above
#in order to confirm creation of network and terminal cfg files.
        Net::SSH.start(ip.to_s, 'foobar', password: "somekindofpassword") do |ssh|
          @grep = ssh.exec!("#{@cat} | egrep 'network|terminal'")
        end
        expect((@grep.include? "network") &&
          (@grep.include? "terminal")).to be true
      end
    end
    describe 'Step 39: Admin; Users; admin' do
      it "should create/edit/remove/impersonate" do
        sleep(2)
        @browser.ul(class: %w(nav nav-second-level collapse in)).
          a(text: "Users").click
        @browser.button(value: "user create").click
        @browser.text_field(id: "input-username").set "foobar"
        @browser.checkbox.click
        @browser.ul(class: "select2-selection__rendered").click
        @browser.send_keys "star"
        @browser.send_keys :enter
        @browser.text_field(id: "input-email").set "#removed"
        @browser.text_field(id: "input-name").set "bar"
        @browser.text_field(id: "input-password").set UPASSWD
        @browser.text_field(id: "input-password2").set UPASSWD
        @browser.checkbox(index: 5).click
        @browser.button(value: "Create").click
        @browser.select_list(name: "users_table_length").
          option(value: "25").click
        expect(@browser.text.include? "foobar").to be true
        @browser.button(value: "edit", index: -1).click
        @browser.text_field(id: "input-email").set "#removed"
        @browser.button(value: "Save changes").click
        @browser.select_list(name: "users_table_length").
          option(value: "25").click
        expect(@browser.text.include? "#removed").to be true
        @browser.button(visible_text: "[ remove ]", index: -1).click
        sleep(1)
        @browser.button(id: "btnRemoveUserYes").click
        sleep(1)
        expect((@browser.text.include? "foobar") &&
          (@browser.text.include? "#removed")).to be false
        username = @browser.table.tr(index: -1).td(index: 2).text
        @browser.button(value: "impersonate", index: -1).click
        expect(@browser.button(visible_text: "Account - #{username}").
          present?).to be true
      end
    end
    describe 'Step 40: homepage(admin)' do
      it "should view all the vessels on the map" do
        logout
        admin_login
        if @browser.select(id: "company_select_id").text != "--- all ---"
          @browser.select(id: "company_select_id").click
          @browser.select(id: "company_select_id").option(value: "").click
        end
        sleep(1)
        admin_vessels_map = @browser.div(class: 'gm-style').
          text.split("\n").uniq
        4.times { admin_vessels_map.pop }
#In order to assert that all vessels appear on the map, more than 30
#have to be counted, which is more vessels than any single company has.
        expect(admin_vessels_map.length > 30).to be true
      end
      it "should view all vessels status and information at the table" do
        if @browser.div(id: 'vessels_table_datatable_wrapper').exists?
          @browser.a(class: %w(btn btn-default buttons-collection
            buttons-page-length)).click
          @browser.ul(class: %w(dt-button-collection dropdown-menu)).
            li(index: 3).click
        end
        expect(@browser.table(id: 'vessels_table_datatable').
          row.cells.length == 11).to be true
        expect(@browser.table(id: 'vessels_table_datatable').
          rows.count > 30).to be true
      end
    end
    describe 'Step 41: Basic Scenario' do
      it "the user should view only his vessels" do
        @browser.span(class: 'nav-label', text: 'Admin').click
        @browser.ul(class: %w(nav nav-second-level collapse in)).
          a(text: "Vessels").click
        if @browser.table(id: "id_vessels").tr(index: 66).td(index: 11).
            checkbox.checked? == false
          @browser.table(id: "id_vessels").tr(index: 66).td(index: 11).
            checkbox.click
        end
        if @browser.table(id: "id_vessels").tr(index: 66).td(index: 13).
            checkbox.checked? == false
          @browser.table(id: "id_vessels").tr(index: 66).td(index: 13).
            checkbox.click
        end
        @browser.button(value: "Save").click
        sleep(4)
        @browser.ul(class: %w(nav nav-second-level collapse in)).
          a(text: "Users").click
        passwd_change('3')
        passwd_change('9')
        logout
        user_login('foobar',UPASSWD)
        passwd_expired
        @browser.goto @browser.url + '?company_id=158&vessel_id=900'
        expect(@browser.text.include?'foobar').to be true
        logout
        user_login('asgl',UPASSWD)
        passwd_expired
        @browser.goto @browser.url + '?company_id=158&vessel_id=900'
        expect(@browser.text.include?'foobar').to be true
      end
    end
    describe 'Step 42: Login page; correct username & password; simple user' do
      it "should redirect you to the homepage" do
        expect(@browser.text.include?'Dashboard').to be true
      end
    end
    describe 'Step 43: homepage(simple user; correct company)' do
      it "should view the vessels of the company on the map" do
        expect(@browser.div(class: 'gm-style').
          text.include? 'foobar').to be true
      end
      it "should view vessel status & information at the table" do
        expect(@browser.div(id: 'vessels_table_datatable_wrapper').
          exists?).to be true
        expect(@browser.table(id: 'vessels_table_datatable').
          row.cells.length == 11).to be true
        expect(@browser.table(id: 'vessels_table_datatable').
          text.include? 'comix status').to be true
      end
    end
    describe 'Step 44: homepage(simple user; wrong company)' do
      it "should display the vessels of the user's company" do
        @browser.goto HOMEPAGE + '?company_id=158'
        expect(@browser.table(id: 'vessels_table_datatable').
          tbody.td.text.match?(/(foobar)/)).to be true
      end
    end
    describe 'Step 45: homepage map' do
      it "should zoom in/out, vessels return info" do
        expect(2.times{@browser.button(title: 'Zoom in').click}).to be 2
        expect(@browser.button(title: 'Zoom out').click).to be nil
        puts "\nPlease check that the vessels on the map return info"
        puts "when clicked. The test will continue in 30 seconds."
        sleep(30)
      end
    end
    describe 'Step 46: homepage (vessels table)' do
      it "should display comix status vessels & working table buttons" do
        sorting(1,'foobar')
        sorting(6,'foobar')
      end
    end
    describe 'Dashboards' do
      describe 'Step 47: Internet traffic (simple user)' do
        it "should view company's internet traffic" do
          @browser.span(class: 'nav-label', text: 'Dashboards').click
          @browser.ul(class: %w(nav nav-second-level collapse in)).
            a(text: "Internet Traffic").click
          expect((@browser.text.include? 'Fleet traffic') &&
          (@browser.text.include?'#removed')).to be true
        end
      end
      describe 'Step 48: Internet traffic (simple user; wrong company)' do
        it "should display the vessels of the user's company" do
          @browser.goto HOMEPAGE + 'dashboards/?company_id=158'
          expect(@browser.text.include? '#removed').to be true
        end
      end
      describe 'Step 49: Internet traffic; months' do
        it "should display the selected month's data" do
          @browser.div(text: MONTH).click
          $month = MONTH.capitalize
          expect((@browser.text.include? 'Fleet traffic') &&
            (@browser.text.include? "#{$month} #{YEAR}")).to be true
        end
      end
      describe 'Step 50: Internet traffic; correct vessel' do
        it "should display the sellected vessel's data" do
          @browser.element(text: '#removed').click
          expect((@browser.text.include? 'All vessels') &&
            (@browser.text.include? "#removed - #{$month} #{YEAR}")).
            to be true
        end
      end
      describe 'Step 51: Internet traffic; wrong vessel' do
        it "should display 'Error 404'" do
          error_404
        end
      end
      describe 'Step 52: Internet traffic; correct vessel; day' do
        it "should display the selected date's data" do
          table_id = "business_traffic_totals_per_day_report_vessel_datatable"
          date = @browser.table(id: "#{table_id}").tr(index: 5).td.text
          day_array = date.split
          day = day_array[1,2]
          @browser.table(id: "#{table_id}").tr(index: 5).td.a.click
          expect((@browser.text.match?(/#{@month}/)) &&
            (@browser.text.match?(/#{day.join(" ")}/))).to be true
        end
      end
      describe 'Step 53: Internet traffic; wrong vessel; day' do
        it "should display 'Error 404'" do
          error_404
        end
      end
      describe 'Step 54: Fuel Consumption; correct vessel' do
        it "should display 'no flow meter connected'" do
          @browser.ul(class: %w(nav nav-second-level collapse in)).
            a(text: "Fuel Consumption").click
          @browser.div(class: %w(list-group panel)).
            a(visible_text: /Tankers/).click
          @browser.div(id: 'company-id-89').a(index: 10).click
          expect(@browser.text.include? 'no flow meter connected').to be true
        end
      end
      describe 'Step 55: Fuel consumption; wrong vessel' do
        it "should display the user's company vessels" do
          wrong_vessel("#removed")
        end
      end
    end
    describe 'Reports' do
      describe 'Step 56: VSAT availability; correct vessel' do
        it "should display the result at map" do
          @browser.span(class: 'nav-label', text: 'Reports').click
          @browser.ul(class: %w(nav nav-second-level collapse in)).
            a(text: "VSAT Availability").click
          @browser.select_list(id: 'id_vessel').click
          @browser.option(value: '1157').click
          puts "\nPlease check that you can see the red dots on the map"
        end
        it "should display the vessel's data at the clicked point" do
          puts "\nand that you can view the vessel's data when clicked."
          puts 'The test will continue in 30 seconds.'
          sleep(30)
        end
        it "should display the selected satellite/s" do
          @browser.ul(class: 'select2-selection__rendered').click
          @browser.li(id: /nSS12$/).click
          @browser.ul(class: 'select2-selection__rendered').click
          @browser.li(id: /sES4$/).click
          puts "\nPlease check that you can see the satellites on the map"
          puts "and that you can view the satellites' data when clicked."
          puts 'The test will continue in 30 seconds.'
          sleep(30)
        end
        it "should display the selected date range's data" do
          vsat_availability("from",6,TRIANGLE_WEST,3,2)
          vsat_availability("to",3,TRIANGLE_WEST,4,2)
          $from_date = @browser.input(id: "datepicker_from").value
          $to_date = @browser.input(id: 'datepicker_to').value
          @browser.input(class: %w(btn btn-info)).click
          expect(@browser.input(id: 'datepicker_from').
            value == $from_date).to be true
          expect(@browser.input(id: 'datepicker_to').
            value == $to_date).to be true
        end
        it "should download CSV file" do
          $from_date = $from_date.gsub("/","-")
          $to_date = $to_date.gsub("/","-")
          @browser.input(name: "Export").click
          sleep(3)
          files = Dir.entries "#{Dir.pwd}"
          expect(files.include? "vsat_#{$from_date}_#{$to_date}.csv").to be true
          File.delete "vsat_#{$from_date}_#{$to_date}.csv"
        end
      end
      describe 'Step 57: VSAT availability; wrong company' do
        it "should display a list with the user's company vessels" do
          @browser.goto @browser.url.gsub("0","158")
          expect(@browser.select_list(id: 'id_vessel').
            text.match? /#removed/).to be true
        end
      end
      describe 'Step 58: Comix uptime; correct company' do
        it "should display the company's vessels' uptimes" do
          @browser.ul(class: %w(nav nav-second-level collapse in)).
            a(text: "Comix Uptime").click
          @browser.option(index: 1).click
          expect((@browser.text.include? "uptime") &&
            (@browser.text.include? "UTC")).to be true
        end
      end
      describe 'Step 59: Comix uptime; wrong company' do
        it "should display the user's company's vessels' uptimes" do
          wrong_company
        end
      end
      describe 'Step 60: Business Traffic; Applications; correct company' do
        it "should display data for the selected date range" do
          @browser.ul(class: %w(nav nav-second-level collapse in)).
            a(text: "Business Traffic").click
          sleep (1)
          @browser.ul(class: %w(nav nav-third-level collapse in)).
            a(text: "Applications").click
          business_traffic("bussiness_result_table")
        end
      end
      describe 'Step 61: Business Traffic; Applications; wrong company' do
        it "should display data for the user's company vessels" do
          wrong_company
        end
      end
      describe 'Step 62: Business Traffic; Volume; correct company' do
        it "should display data for the selected date range" do
          @browser.ul(class: %w(nav nav-third-level collapse in)).
            a(text: "Volume").click
          business_traffic("bussiness_volume_result_table")
        end
      end
      describe 'Step 63: Business Traffic; Volume; wrong company' do
        it "should display data for the user's company vessels" do
          wrong_company
        end
      end
      describe 'Step 64: Crew Traffic; Domains; correct company' do
        it "should display data for the selected date range" do
          @browser.ul(class: %w(nav nav-second-level collapse in)).
            a(text: "Crew Traffic").click
          sleep (2)
          crew_traffic(0)
          sleep(1)
          range_assertions("crew_domains_result_table",@from_month,@to_month)
        end
      end
      describe 'Step 65: Crew Traffic; Domains; wrong company' do
        it "should display data for the user's company vessels" do
          wrong_company
        end
      end
      describe 'Step 66: Crew Traffic; Volume; correct volume' do
        it "should display data for the selected date range" do
          crew_traffic(2)
          sleep(1)
          range_assertions("crew_volume_result_table",@from_month,@to_month)
        end
      end
      describe 'Step 67: Crew Traffic; Volume; wrong company' do
        it "should display data for the user's company vessels" do
          wrong_company
        end
      end
      describe 'Step 68: Crew Traffic; Pins; correct company' do
        it "should display data for the selected date range" do
          crew_traffic(1)
          sleep(1)
          range_assertions("pins_report_result_table",@from_month,@to_month)
        end
      end
      describe 'Step 69: Crew Trafic; Pins; wrong company' do
        it "should display data for the user's company vessels" do
          wrong_company
        end
      end
    end
    describe 'Services; Alerts' do
      describe 'Step 70: ECDIS; correct vessel' do
        describe 'Create/Edit' do
          it "should redirect to ECDIS page" do
            @browser.span(class: 'nav-label', text: 'Services').click
            @browser.ul(class: %w(nav nav-second-level collapse in)).
              a(text: "Alerts").click
            sleep(1)
            @browser.ul(class: %w(nav nav-second-level collapse in)).
              ul(class: %w(nav nav-third-level collapse in)).
              a(text: "ECDIS").click
            @browser.div(class: "config-align-vessels").a.click
            if @browser.text.include? "Enabled: true"
              @browser.button(id: "edit-ecdis-alert").click
            else
              @browser.button(id: "create-ecdis-alert").click
            end
            @browser.text_field(id: "input-imonumber").set imo_number
            @browser.button(value: "Create").click
            expect(@browser.text.include? "Enabled: true").to be true
          end
        end
        describe 'Remove' do
          it "should remove vessel from ECDIS" do
            @browser.button(id: "delete-ecdis-alert").click
            sleep(1)
            @browser.button(id: "btn-ecdis-alert-delete-modal").click
            sleep(1)
            expect(@browser.text.include? "Enabled: true").to be false
          end
        end
        describe 'help' do
          it "should display the help modal" do
            help_modal("ECDIS Notification Help")
          end
        end
      end
      describe 'Step 71: ECDIS; wrong vessel' do
        it "should display the user's company vessels" do
          wrong_vessel("#removed")
        end
      end
      describe 'Step 72: Sat Loss; correct vessel' do
        describe 'Create/Edit' do
          it "should redirect to Vessel's Sat Loss page" do
            @browser.ul(class: %w(nav nav-third-level collapse in)).
              a(text: "Sat Loss").click
            @browser.div(class: "config-align-vessels").a.click
            if (@browser.text.include? "Enabled: true") ||
              (@browser.text.include? "Enabled: false")
              @browser.button(id: "edit-satloss-alert").click
            else
              @browser.button(id: "create-satloss-alert").click
            end
            @browser.text_field(id: "input-targetmail").set Email
            @browser.text_field(id: "input-threshold").set "5"
            @browser.send_keys :tab
            6.times {@browser.span(class: TRIANGLE_WEST).click}
            @browser.table(class: 'ui-datepicker-calendar').
              tr(index: 3).td(index: 3).click
            @browser.button(value: "Create").click
            expect((@browser.text.include? Email)).to be true
          end
        end
        describe 'Enable/Disable Alerts' do
          it "should enable/disable the vessel's Sat Loss" do
            @browser.button(id: "toggle-satloss-alert").click
            sleep(1)
            @browser.button(id: "btn-satloss-alert-toggle-modal").click
            sleep(2)
            expect((@browser.text.include? "Enabled: true") ||
              (@browser.text.include? "Enabled: false")).to be true
          end
        end
        describe 'Help' do
          it "should display the help modal" do
            help_modal("Sat Loss Alerts Help")
          end
        end
      end
      describe 'Step 73: Sat Loss; wrong vessel' do
        it "should display the user's company vessels" do
          wrong_vessel("#removed")
        end
      end
      describe 'Step 74: Voice Calls; Correct Vessel' do
        describe 'Create/Edit'do
          it "should redirect to Vessel's Voice Calls page" do
            @browser.ul(class: %w(nav nav-third-level collapse in)).
              a(text: "Voice Calls").click
            @browser.div(class: "config-align-vessels").a.click
            if (@browser.text.include? "Enabled: true") ||
              (@browser.text.include? "Enabled: false")
              @browser.button(id: "edit-voice-alert").click
            else
              @browser.button(id: "create-voice-alert").click
            end
            @browser.text_field(id: "input-targetmail").set Email
            @browser.text_field(id: "input-threshold").set "5"
            @browser.text_field(id: "input-secthreshold").set "10"
            @browser.send_keys :tab
            6.times {@browser.span(class: TRIANGLE_WEST).click}
            @browser.table(class: 'ui-datepicker-calendar').
              tr(index: 3).td(index: 3).click
            $start_date = @browser.text_field(id: "input-starttime").value
            @browser.button(value: "Create").click
            expect((@browser.text.include? "Enabled: true") &&
              (@browser.text.include? Email)).to be true
          end
        end
        describe 'Reset/Enable/Disable Alerts' do
          it "should reset/enable/disable the vessel's alerts" do
            @browser.button(id: "reset-voice-alert").click
            sleep(1)
            @browser.button(id: "btn-voice-alert-reset-modal").click
            sleep(2)
            expect(@browser.text.include? $start_date.to_s).to be false
            if @browser.text.include? "Enabled: true"
              @browser.button(id: "toggle-voice-alert").click
              sleep(1)
              @browser.button(id: "btn-voice-alert-toggle-modal").click
              sleep(2)
              expect(@browser.text.include? "Enabled: true").to be false
            else
              @browser.button(id: "toggle-voice-alert").click
              sleep(1)
              @browser.button(id: "btn-voice-alert-toggle-modal").click
              sleep(2)
              expect(@browser.text.include? "Enabled: true").to be true
            end
          end
        end
        describe 'Help' do
          it "should display the help modal" do
            help_modal("Voice Calls Alerts Help")
          end
        end
      end
      describe 'Step 75: Voice Calls; wrong vessel' do
        it "should display the user's company vessels" do
          wrong_vessel("#removed")
        end
      end
      describe 'Step 76: Com Loss; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Com Loss").to be true
        end
      end
      describe 'Step 77: Node Offline; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Node Offline").to be true
        end
      end
      describe 'Step 78: CPU; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "CPU").to be false
        end
      end
      describe 'Step 79: RAM; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "RAM").to be false
        end
      end
      describe 'Step 80: Disk; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Disk").to be false
        end
      end
      describe 'Step 81: GPos; Correct Vessel' do
        describe 'Create/Edit'do
          it "should redirect to Vessel's GPos page" do
            @browser.ul(class: %w(nav nav-third-level collapse in)).
              a(text: "GPos").click
            @browser.div(class: "config-align-vessels").a.click
            @browser.button(id: "create-gpos-alert").click
            @browser.text_field(id: "input-targetmail").set Email
            @browser.text_field(id: "input-label").set "foobar"
            @browser.text_field(id: "input-threshold").set "5"
            @browser.send_keys :tab
            6.times {@browser.span(class: TRIANGLE_WEST).click}
            @browser.table(class: 'ui-datepicker-calendar').
              tr(index: 3).td(index: 3).click
            $latitude = rand(-90.000000000...90.000000000)
            $longitude = rand(-180.000000000...180.000000000)
            @browser.text_field(id: "input-targetlocation").
              set "#{$latitude},#{$longitude}"
            @browser.button(value: "Create").click
            expect(@browser.text.include? "#{$latitude},#{$longitude}").
              to be true
          end
        end
        describe 'Enable/Disable/Remove Alerts' do
          it "should enable/disable/remove the vessel's alerts" do
            @browser.button(class: %w(btn btn-xs
              btn-primary toggle-gpos-alert)).click
            sleep(1)
            @browser.button(id: "btn-gpos-alert-toggle-modal").click
            sleep(2)
            expect(@browser.text.include? "false").to be true
            @browser.button(class: %w(btn btn-xs btn-danger delete-gpos-alert),
              index: -1).click
            sleep(1)
            @browser.button(id: "btn-gpos-alert-delete-modal").click
            sleep(2)
            expect(@browser.text.include? "#{$latitude},#{$longitude}").
              to be false
          end
        end
        describe 'Help' do
          it "should display the help modal" do
            help_modal("GPos Alerts Help")
          end
        end
      end
      describe 'Step 82: GPos; wrong vessel' do
        it "should display the user's company vessels" do
          wrong_vessel("#removed")
        end
      end
      describe 'Step 83: Data Volume; Per Vessel; Correct Vessel' do
        describe 'Create/Edit'do
          it "should redirect to Per Vessel page" do
            @browser.ul(class: %w(nav nav-third-level collapse in)).
              a(text: "Data Volume").click
            @browser.ul(class: %w(nav nav-fourth-level collapse in)).
              a(text: "Per Vessel").click
            @browser.div(class: "config-align-vessels").a.click
            data_vol("per-terminal","terminals","Data Volume Alerts Help")
            $id = @browser.table.tr(index: 1).td.text
          end
        end
        describe 'Help' do
          it "should display the help modal" do
            help_modal("Data Volume Alerts Help")
          end
        end
        describe 'Enable/Disable/Reset/Remove Alerts' do
          it "should enable/disable/reset the vessel's alerts" do
            en_dis_res_rem_alerts("","per-terminal")
          end
        end
      end
      describe 'Step 84: Data Volume; Per Vessel; wrong vessel' do
        it "should display the user's company vessels" do
          wrong_vessel("#removed")
        end
      end
      describe 'Step 85: Data Volume; SCAP; Correct Vessel' do
        describe 'Create/Edit'do
          it "should redirect to Vessel's SCAP page" do
            @browser.ul(class: %w(nav nav-fourth-level collapse in)).
              a(text: "SCAP").click
            data_vol("scap","vessels","SCAP Data Volume Alerts Help")
            $id = @browser.table.tr(index: 1).td.text
            @browser.button(id: "edit-data-volume-scap-alert-#{$id}").click
            @browser.text_field(id: "input-targetmail").
              append ",#removed"
            multiple_emails = @browser.text_field(id: "input-targetmail").value
            @browser.button(value: "Save changes").click
            expect(@browser.text.include? multiple_emails).to be true
          end
        end
        describe 'Help' do
          it "should display the help modal" do
            help_modal("SCAP Data Volume Alerts Help")
          end
        end
        describe 'Enable/Disable/Reset/Remove Alerts' do
          it "should enable/disable/reset/remove the vessel's alerts" do
            en_dis_res_rem_alerts("scap-","scap")
          end
        end
      end
      describe 'Step 86: Data Volume; SCAP; wrong company' do
        it "should display the user's company vessels" do
          wrong_company
        end
      end
      describe 'Step 87: Massive Alerts; Com Loss; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Massive Alerts").to be false
        end
      end
      describe 'Step 88: Massive Alerts; Node Offline; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Massive Alerts").to be false
        end
      end
      describe 'Step 89: Massive Alerts; CPU; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Massive Alerts").to be false
        end
      end
      describe 'Step 90: Massive Alerts; RAM; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Massive Alerts").to be false
        end
      end
      describe 'Step 91: Massive Alerts; Disk; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Massive Alerts").to be false
        end
      end
      describe 'Step 92: Global Configuration; Cloud Server; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Global").to be false
        end
      end
      describe 'Step 93: Global Configuration; Domain profiles; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Global").to be false
        end
      end
      describe 'E-mail Vessel Configuration' do
        describe 'Step 94: Comix; correct vessel' do
          it "should redirect to Comix page" do
            @browser.ul(class: %w(nav nav-second-level collapse in)).
              a(text: "E-mail").click
            sleep(1)
            @browser.ul(class: %w(nav nav-third-level collapse in)).
              a(text: "Comix").click
            @browser.div(class: "config-align-vessels").a.click
            if @browser.button(value: "email create").present?
              @browser.button(value: "email create").click
              @browser.text_field(id: "input-smtp-relay-address").
                set "#removed"
              @browser.text_field(id: "input-smtp-relay-port").set "587"
              @browser.text_field(id: "input-incoming-poll-address").
                set "#removed"
              @browser.text_field(id: "input-incoming-poll-port").set "587"
              @browser.text_field(id: "input-incoming-poll-protocol").set "imap"
              @browser.text_field(id: "input-incoming-poll-ssl").set "1"
              @browser.text_field(id: "input-incoming-poll-timeout").set "5"
              @browser.text_field(id: "input-incoming-poll-interval").set "5"
              @browser.text_field(id: "input-outgoing-size-limit").set "512"
              @browser.text_field(id: "input-incoming-size-limit").set "512"
              @browser.text_field(id: "input-outgoing-hold").set "0"
              checkbox_enable
              @browser.button(value: "Create").click
            end
            expect(@browser.text.include? "Email Configuration").to be true
          end
          it "should display 'Saved OK'" do
            unless @browser.text.include? "Saving..."
              @browser.button(id: "email-apply").click
              sleep(1)
              @browser.button(id: "btnApplyEmailComixYes").click
              sleep(2)
              @browser.button(text: "OK").click
              Watir::Wait.until(timeout: 120) {(@browser.text.
                include? "Saved OK")}
              expect(@browser.text.include? "Saved OK").to be true
            end
          end
        end
        describe 'Step 95: Comix; wrong vessel' do
          it "should display the user's company vessels" do
            wrong_vessel("#removed")
          end
          it "should display 'Error 404'(create,edit)" do
            @browser.div(class: "config-align-vessels").a.click
            @browser.button(value: "edit").click
            error_404
          end
        end
        describe 'Step 96: Accounts; correct vessel' do
          it "should redirect to Accounts page" do
            @browser.ul(class: %w(nav nav-third-level collapse in)).
              a(text: "Accounts").click
            email_account("foobar")
            email_account("foo")
            email_account("bar")
          end
          it "should remove account" do
            address = @browser.table(id: "email_acounts_table").
              tr(index: 1).td(index: 2).text
            @browser.button(class: %w(btn btn-danger
              btn-sm btnEmailAcountDelete)).click
            sleep(1)
            @browser.button(id: "btnRemoveEmailAcountYes").click
            sleep(1)
            expect(@browser.table(id: "email_acounts_table").tr(index: 1).
              td(index: 2).text.match? /"#{address}"/).to be false
          end
        end
        describe 'Step 97: Accounts; wrong vessel' do
          it "should display the user's company vessels" do
            wrong_vessel("#removed")
          end
          it "should display 'Error 404'(create,edit)" do
            @browser.div(class: "config-align-vessels").a.click
            @browser.button(value: "email create").click
            error_404
          end
        end
        describe 'Step 98: Inwards white list; correct vessel' do
          it "should redirect to inwards white list page" do
            @browser.ul(class: %w(nav nav-second-level collapse in)).
              a(text: "Inwards white list").click
            lists_config("Internal","Incoming","white","internal","incoming",
              "External","external")
          end
        end
        describe 'Step 99: Inwards white list; wrong vessel' do
          it "should display 'Error 404'(edit)" do
            error_404
          end
          it "should display the user's company vessels" do
            @browser.back
            wrong_vessel("#removed")
          end
        end
        describe 'Step 100: Outwards white list; correct vessel' do
          it "should redirect to outwards white list page" do
            @browser.ul(class: %w(nav nav-second-level collapse in)).
              a(text: "Outwards white list").click
            @browser.div(class: "config-align-vessels").a.click
            lists_config("Internal","Outgoing","white","internal","outgoing",
              "External","external")
          end
        end
        describe 'Step 101: Outwards white list; wrong vessel' do
          it "should display 'Error 404'(edit)" do
            error_404
          end
          it "should display the user's company vessels" do
            @browser.back
            wrong_vessel("#removed")
          end
        end
        describe 'Step 102: Inwards black list; correct vessel' do
          it "should redirect to inwards black list page" do
            @browser.ul(class: %w(nav nav-second-level collapse in)).
              a(text: "Inwards black list").click
            @browser.div(class: "config-align-vessels").a.click
            lists_config("Internal","Incoming","black","internal","incoming",
              "External","external")
          end
        end
        describe 'Step 103: Inwards black list; wrong vessel' do
          it "should display 'Error 404'(edit)" do
            error_404
          end
          it "should display the user's company vessels" do
            @browser.back
            wrong_vessel("#removed")
          end
        end
        describe 'Step 104: Outwards black list; correct vessel' do
          it "should redirect to outwards black list page" do
            @browser.ul(class: %w(nav nav-second-level collapse in)).
              a(text: "Outwards black list").click
            @browser.div(class: "config-align-vessels").a.click
            lists_config("Internal","Outgoing","black","internal","outgoing",
              "External","external")
          end
        end
        describe 'Step 105: Outwards black list; wrong vessel' do
          it "should display 'Error 404'(edit)" do
            error_404
          end
          it "should display the user's company vessels" do
            @browser.back
            wrong_vessel("#removed")
          end
        end
      end
      describe 'Step 106: Firewall; Correct Vessel' do
        it "should display 'Saved OK'" do
          @browser.ul(class: %w(nav nav-second-level collapse in)).
            a(text: "Cyber Security").click
          sleep(1)
          @browser.ul(class: %w(nav nav-third-level collapse in)).
            a(text: "Firewall").click
          @browser.div(class: "config-align-vessels").a.click
          @browser.div(class: "ibox-content", index: 2).a.click
          sleep(1)
          @browser.table.tr(index: -1).checkbox(index: 0).click
          @browser.table.tr(index: -1).checkbox(index: 1).click
          filter(0,0,"192.168.88.100")
          filter(0,1,"any")
          filter(0,2,"PING")
          filter(0,3,"192.168.191.100")
          filter(0,4,"any")
          @browser.table.tr(index: -1).a(index: 5).click
          @browser.div(class: "editable-input").select_list.click
          @browser.div(class: "editable-input").option(value: "icmp").click
          @browser.div(class: "editable-buttons").button.click
          @browser.ul(class: %w(nav nav-tabs)).li(index: 1).click
          @browser.div(class: "ibox-content", index: 3).a.click
          sleep(1)
          @browser.table(index: 1).tr(index: -1).checkbox(index: 0).click
          @browser.table(index: 1).tr(index: -1).checkbox(index: 2).click
          @browser.table(index: 1).tr(index: -1).checkbox(index: 3).click
          filter(1,0,"TELE2")
          filter(1,1,"30.130.70.73")
          filter(1,2,"80")
          @browser.table(index: 1).tr(index: -1).a(index: 3).click
          @browser.div(class: "editable-input").select_list.click
          @browser.div(class: "editable-input").option(value: "tcp").click
          @browser.div(class: "editable-buttons").button.click
          @browser.button(value: "Save").click
          Watir::Wait.until(timeout: 120) {(@browser.text.include? "Saved OK")}
          expect(@browser.text.include? "Saved OK").to be true
        end
        it "should add firewall rules to the config files" do
#Parses and then pings the current url in order to extract the IP address
#of the local DM test server (usually 10.0.0.47).
          url = @browser.url.match /\/\/[a-z0-9]*.[a-z0-9]*.[a-z0-9]*.[0-9]*/
          domain = url.to_s.split("/")[-1]
          ip = `ping -c1 #{domain}`.split("\n")[0].
            match /[0-9]*[.][0-9]*[.][0-9]*[.][0-9]*/
          @govess = "cd /home/companies/88/vessels/1039/out/admin/vessel/slash/"
          @cat = "#{@govess}opt/comix/config; cat filterin.cfg filterout.cfg"
#Establishes SSH connection to the IP address fetched from above
#in order to confirm addition of the firewall rules to the config files.
          Net::SSH.start(ip.to_s, '#removed', password: "somekindofpassword") do |ssh|
            @grep = ssh.exec!("#{@cat} | egrep 'TELE2|PING'")
          end
          expect((@grep.include? "PING") && (@grep.include? "TELE2") &&
            (@grep.match? /FOUT_VOIP\[\d+\]=1/)).to be true
          @browser.table(index: 1).tr(index: -1).button.click
          sleep(1)
          @browser.button(id: "btnFoutYes").click
          sleep(1)
          @browser.ul(class: %w(nav nav-tabs)).li(index: 0).click
          sleep(1)
          @browser.table(index: 0).tr(index: -1).button.click
          sleep(1)
          @browser.button(id: "btnFinYes").click
          sleep(1)
          @browser.button(value: "Save").click
          Watir::Wait.until(timeout: 120) {(@browser.text.include? "Saved OK")}
        end
      end
      describe 'Step 107: Firewall; wrong vessel'do
        it "should display the user's company vessels" do
          wrong_vessel("#removed")
        end
      end
      describe 'Step 108: GPos; correct vessel' do
        it "should display the selected weather overlay on map" do
          @browser.ul(class: %w(nav nav-second-level collapse in)).
            a(visible_text: /GPos/).click
        end
        it "should toggle the day/night overlay" do
          puts "\nPlease manually check the Day/Night toggle, weather overlays,"
        end
        it "should change the opacity of the overlays" do
          puts "\noverlay opacity, etc. The test will continue in 60 seconds."
        end
        it "should display the weather for the selected date" do
          sleep(60)
        end
      end
      describe 'Step 109: GPos; wrong vessel' do
        it "should display an empty map" do
          @browser.goto @browser.url + "&vessel_id=624"
          sleep(2)
          expect(@browser.div(class: 'gm-style').text.split("\n").length == 4).
            to be true
        end
      end
      describe 'Step 110: Diagnostics; Fleet Inventory; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Diagnostics").to be false
        end
      end
      describe 'Step 111: Admin; Vessels; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Admin").to be false
        end
      end
      describe 'Step 112: Admin; Users; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Admin").to be false
        end
      end
      describe 'Step 113: Admin; Config; user' do
        it "should not be accessible" do
          expect(@browser.text.include? "Admin").to be false
        end
      end
      describe 'Step 114: Feedback form' do
        it "should check that you've received an e-mail." do
          @browser.span(text: "Feedback Form").click
          @browser.select_list(name: "subject").option(value: "4").click
          @browser.textarea(id: "input-message").set "It's a feature not a bug."
          @browser.button(id: "sent").click
          expect(@browser.text.include? "Feedback sent").to be true
puts """\nPlease check that you have received the following number of e-mails
in your e-mail address at #{Email}:
\n4 e-mails for failing to enter the correct credentials for username 'foobar'.
1 e-mail for failing to enter the correct credentials for username 'barfoo'.
1 e-mail for Comix Crew PIN creation.
1 e-mail with the subject 'Other' from the feedback form."""
sleep(15)
puts "\nThis concludes the execution of the Regression Test Plan."
sleep(8)
        end
      end
    end
    after :all do
      @browser.close
    end
  end
end
