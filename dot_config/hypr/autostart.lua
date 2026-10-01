-- Extra autostart processes — Omarchy quattro twin of the host's autostart.conf.
-- o.launch_on_start() runs the command through uwsm-app as part of the
-- session, so it is cleaned up on logout.

-- Clipboard history watcher (host parity). Skipped on machines without
-- cliphist / wl-clipboard, where the command would just fail at login.
if o.cmd_present("cliphist") and o.cmd_present("wl-paste") then
  o.launch_on_start("wl-paste --type text --watch cliphist store")
end
