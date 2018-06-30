def #removed
  @browser.text_field(name: 'username').set(Uname)
  @browser.text_field(name: 'password').set(Passwd)
  @browser.button(value: 'Log in').click
  puts "\nPlease enter the 2FA code in the browser window"
  puts "and then press the Login button."
  until @browser.text.include?'Dashboard'
    Watir::Wait.until(timeout: 120) {(@browser.text.include?'Dashboard')||
      ((@browser.text.include? 'Username') &&
      (@browser.text.include? "Password"))}
    if (@browser.text.include? 'Username') &&
      (@browser.text.include? "Password")
      @browser.text_field(name: 'username').set(Uname)
      @browser.text_field(name: 'password').set(Passwd)
      @browser.button(value: 'Log in').click
      puts "\nPlease enter the 2FA code in the browser window"
      puts "and then press the Login button."
    end
  end
end

def logout
  @browser.button(text: /^Account/).click
  @browser.a(href: '/auth/logout/').click
end

def passwd_change(id)
  @browser.button(onclick: "location.href = './edit/?user_id=#{id}';").click
  @browser.text_field(id: 'input-password').set(UPASSWD)
  @browser.text_field(id: 'input-password2').set(UPASSWD)
  @browser.button(value: 'Save changes').click
end

def user_login(uname,passwd)
  @browser.text_field(name: 'username').set(uname)
  @browser.text_field(name: 'password').set(passwd)
  @browser.button(value: 'Log in').click
end

def launch
  prefs = {
    download: {
      prompt_for_download: false,
      default_directory: "#{Dir.pwd}"
    }
  }
  @browser = Watir::Browser.new :chrome, options: {timeout: 60, prefs: prefs}
  @browser.goto 'https://example.org'
end

def required(name)
  required = @browser.text_field(name: name).attribute('required')
  expect(required.include? 'true').to be true
end

def recaptcha(prompt)
  @browser.iframe.click
  sleep(3)
  if @browser.iframe(title: 'recaptcha challenge').visible? == true
    puts "\n#{prompt}"
    Watir::Wait.until(timeout: 120) {@browser.
      iframe(title: 'recaptcha challenge').visible? == false}
  end
end

def sorting(index,text)
  @browser.tr[index].click
  expect(@browser.td(index: index).text.include? text).to be true
end

def error_404
  @browser.goto @browser.url.gsub(/vessel_id=\d+/,"vessel_id=900")
  expect(@browser.text.include? 'Error 404').to be true
  @browser.back
end

def vsat_availability(from_to,times,triangle,row,data)
  @browser.input(id: "datepicker_#{from_to}").click
  times.times {@browser.span(class: triangle).click}
  @browser.table(class: 'ui-datepicker-calendar').
  tr(index: row).td(index: data).click
end

def wrong_company
  @browser.goto @browser.url.gsub(/company_id=\d+/,"company_id=158")
  @browser.option(index: 1).click
  expect(@browser.text.include? "foobar").to be true
end

def business_traffic(app_vol)
  @browser.text_field(id: "date-start").set $from_date
  @browser.text_field(id: "date-end").set $to_date
  @browser.send_keys :tab
  sleep (1)
  @browser.button(id: "apply-interval").click
  @browser.div(class: %w(dt-buttons btn-group)).a.click
  @browser.ul(class: %w(dt-button-collection dropdown-menu)).li(index: 3).click
  range = @browser.table(id: app_vol).tr(index: 1).td(index: 2).text
  expect(range.include? $from_date).to be true
  range = @browser.table(id: app_vol).tr(index: -1).td(index: 2).text
  expect(range.include? $to_date).to be true
end

def crew_traffic(li)
  @browser.ul(class: %w(nav nav-third-level collapse in)).li(index: li).click
  @browser.text_field(id: "date-start").click
  6.times {@browser.span(class: TRIANGLE_WEST).click}
  @browser.text_field(id: "date-end").click
  3.times {@browser.span(class: TRIANGLE_WEST).click}
  @browser.send_keys :tab
  @from_month = @browser.text_field(id: "date-start").value.split("-")
  if @from_month[1][0] == "0"
    @from_month[1] = @from_month[1][1]
  end
  @to_month = @browser.text_field(id: "date-end").value.split("-")
  if @to_month[1][0] == "0"
    @to_month[1] = @to_month[1][1]
  end
  sleep (1)
  @browser.button(id: "apply-interval").click
  @browser.div(class: %w(dt-buttons btn-group)).a.click
  @browser.ul(class: %w(dt-button-collection dropdown-menu)).li(index: 3).click
end

def range_assertions(doms_vol_pins,from,to)
  2.times {@browser.table(id: doms_vol_pins).th(index: 3).click}
  range = @browser.table(id: doms_vol_pins).tr(index: 1).td(index: 2).text
  expect(range == from[0]).to be true
  range = @browser.table(id: doms_vol_pins).tr(index: 1).td(index: 3).text
  if from[1].to_i > to[1].to_i
    expect(range == "12").to be true
  else
    expect(range == from[1]).to be true
  end
  range = @browser.table(id: doms_vol_pins).tr(index: -1).td(index: 3).text
  if from[1].to_i > to[1].to_i
    expect(range == "1").to be true
  else
    expect(range == to[1]).to be true
  end
  range = @browser.table(id: doms_vol_pins).tr(index: -1).td(index: 2).text
  expect(range == to[0]).to be true
end

def imo_number
  @imo = Array.new
  until @imo.length == 6
    @imo += [rand(1..9)]
  end

  factor = 7
  number = []
  @imo.each do |digit|
    number.push(factor * digit)
    factor -= 1
  end

  check_digit = number.inject(0) {|sum,item| sum + item}
  check_digit = check_digit.to_s[-1].to_i
  @imo.push(check_digit)
  @imo.join
end

def wrong_vessel(vessel)
  @browser.goto @browser.url.gsub(/vessel_id=\d+/,"vessel_id=624")
  expect(@browser.text.include? vessel).to be true
end

def help_modal(text)
  @browser.button(data_toggle: "modal").click
  sleep(1)
  expect(@browser.text.include? text).to be true
  @browser.button(visible_text: "OK").click
  sleep(1)
end

def create_edit(type)
  if @browser.button(id: "create-#{type}-alert").present?
    @browser.button(id: "create-#{type}-alert").click
  else
    @browser.button(id: "edit-#{type}-alert").click
  end
end

def passwd_expired
  if @browser.text.include? "Change password"
    @browser.text_field(id: "old_password").set UPASSWD
    new_passwd = SecureRandom.base64
    @browser.text_field(id: "input-password").set new_passwd
    @browser.text_field(id: "input-password2").set new_passwd
    @browser.button(id: "submit_button_change_user_password").click
    @browser.span(class: 'nav-label', text: 'Home').click
  end
end

def data_vol(scapterm,vessterm,helpmod)
  @browser.button(id: "create-data-volume-#{scapterm}-alert").click
  help_modal(helpmod)
  sleep(1)
  if @browser.checkbox(id: "input-check-all-#{vessterm}").checked? == true
    2.times {@browser.checkbox(id: "input-check-all-#{vessterm}").click}
  else
    @browser.checkbox(id: "input-check-all-#{vessterm}").click
  end
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
  sleep(1)
  expect(@browser.text.include? $start_date).to be true
end

def en_dis_res_rem_alerts(scap,scapterm)
  @browser.button(class: %W(btn btn-xs btn-primary
    toggle-data-volume-#{scap}alert)).click
  sleep(1)
  @browser.button(id: "btn-data-volume-#{scap}alert-toggle-modal").click
  sleep(3)
  expect(@browser.text.include? "false").to be true
  @browser.button(class: %W(btn btn-xs btn-primary
    reset-data-volume-#{scap}alert)).click
  sleep(1)
  @browser.button(id: "btn-data-volume-#{scap}alert-reset-modal").click
  sleep(3)
  expect(@browser.text.include? $start_date.to_s).to be false
  @browser.button(class: %W(btn btn-xs btn-danger
   delete-data-volume-#{scap}alert)).click
  sleep(1)
  @browser.button(id: "btn-data-volume-#{scap}alert-delete-modal").click
  sleep(3)
  expect(@browser.text.include? $id).to be false
end

def checkbox_enable
  if @browser.checkbox(id: "input-incoming-enable").checked? == false
    @browser.checkbox(id: "input-incoming-enable").click
  end
  if @browser.checkbox(id: "input-outgoing-enable").checked? == false
    @browser.checkbox(id: "input-outgoing-enable").click
  end
end

def email_account(uname)
  @browser.button(value: "email create").click
  @browser.text_field(id: "input-identity").set uname
  @browser.text_field(id: "input-address").set "#removed"
  @browser.text_field(id: "password").set UPASSWD
  @browser.text_field(id: "verify-password").set UPASSWD
  @browser.select(id: "profile").click
  @browser.option(value: "#removed").click
  @browser.text_field(id: "input-incoming-username").set "#removed"
  @browser.text_field(id: "incoming-password").set UPASSWD
  @browser.text_field(id: "-verify-incoming-password").set UPASSWD
  @browser.text_field(id: "input-incoming-size-limit").set "512"
  @browser.text_field(id: "input-outgoing-size-limit").set "512"
  @browser.text_field(id: "input-outgoing-username").set "#removed"
  @browser.text_field(id: "outgoing-password").set UPASSWD
  @browser.text_field(id: "verify-outgoing-password").set UPASSWD
  checkbox_enable
  @browser.button(value: "Create").click
  expect(@browser.text.include? "Email Configuration").to be true
end

def lists_config(btnint,btninout,whtblk,tblint,tblinout,btnext,tblext)
  @browser.button(value: "edit").click
  @browser.span(class: %w(select2-selection
    select2-selection--multiple)).click
  @browser.ul(id: "select2-emailAccounts-results").li(index: 1).click
  address = @browser.span(class: %w(select2-selection
    select2-selection--multiple)).text
  address = address.split("").push[1..-1].join
  @browser.button(class: %W(btn btn-info btn-md
    btnAdd#{btnint}EmailAcount#{btninout})).click
  expect(@browser.table(id: "email_comix_#{whtblk}_list_#{tblint}_#{tblinout}").
    tr(index:1).td(index: 1).text.include? address).to be true
  @browser.table(id: "email_comix_#{whtblk}_list_#{tblint}_#{tblinout}").
    button.click
  @browser.text_field(id: "emailAddress").set "#removed"
  address = @browser.text_field(id: "emailAddress").value
  @browser.button(class: %W(btn btn-info btn-md
    btnAdd#{btnext}EmailAcount#{btninout})).click
  expect(@browser.table(id: "email_comix_#{whtblk}_list_#{tblext}_#{tblinout}").
    tr(index:1).td(index: 1).text.include? address).to be true
  @browser.table(id: "email_comix_#{whtblk}_list_#{tblext}_#{tblinout}").
    button.click
end

def en_dis_rem_massalerts(type)
  @browser.checkbox(index: -1).click
  @browser.button(id: "toggle-#{type}-massive-alert").click
  sleep(1)
  @browser.button(id: "btn-#{type}-massive-alert-toggle-modal").click
  sleep(1)
  expect(@browser.table.tr(index: -1).td(index: -2).text.include? "false").to be true
  id = @browser.table.tr(index: -1).td.text
  @browser.checkbox(index: -1).click
  @browser.button(id: "delete-#{type}-massive-alert").click
  sleep(1)
  @browser.button(id: "btn-#{type}-massive-alert-delete-modal").click
  sleep(1)
  expect(@browser.text.include? id).to be false
end

def en_dis_alerts(type)
  if @browser.text.include? "disabled"
    @browser.button(id: "toggle-#{type}-alert").click
    sleep(1)
    @browser.button(id: "btn-#{type}-alert-toggle-modal").click
    sleep(1)
    expect(@browser.text.include? "disabled").to be false
  else
    @browser.button(id: "toggle-#{type}-alert").click
    sleep(1)
    @browser.button(id: "btn-#{type}-alert-toggle-modal").click
    sleep(1)
    expect(@browser.text.include? "disabled").to be true
  end
end

def alert_settings
  @browser.text_field(id: "input-targetmail").set Email
  @browser.text_field(id: "input-threshold").set "30"
  @browser.send_keys :tab
  6.times {@browser.span(class: TRIANGLE_WEST).click}
  @browser.table(class: 'ui-datepicker-calendar').
  tr(index: 3).td(index: 3).click
  sleep(1)
  $start_date = @browser.text_field(id: "input-starttime").value
  @browser.button(value: "Create").click
  expect(@browser.text.include? $start_date).to be true
end

def filter(tindex,trindex,value)
  @browser.table(index: tindex).tr(index: -1).a(index: trindex).click
  @browser.text_field(class: %w(form-control input-sm)).
    set value
  @browser.div(class: "editable-buttons").button.click
end
