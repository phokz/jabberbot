#!/usr/bin/ruby

require 'rubygems'
require 'jabber/bot'

def hostname
  File.open('/etc/hostname').read.split('.').first
end

def basedir
  File.expand_path(File.dirname(__FILE__))
end

FN='jabberbot.conf'

def load_config
    dirs=['/etc', basedir]
    @config={}
    dirs.each do |dir|
      fn=[dir,FN].join('/')
      really_load_config(fn) if File.exists?(fn)
    end
end

def really_load_config f
    File.open(f).read.split("\n").each do |l|
      a=l.split('=')
      k=a.shift
      v=a.join('=')
      @config[k]=v
    end
end

# Create a public Jabber::Bot

load_config

config = {
  :name      => hostname+@config['suffix']+'/'+`whoami`,
  :jabber_id => hostname+@config['suffix']+'@'+@config['domain'],
  :password  => @config['password'],
  :master    => @config['master'],
  :is_public => false
}

bot = Jabber::Bot.new(config)

# commands to implement:
# - pohni mysi - done
# - posli notifikaci na obrazovku
#- pust video z downloads/*part
#- odloguj uzivatele
#- zjisti seznam oken

# Give your bot a private command, 'rand'
bot.add_command(
:syntax      => 'pohni',
:description => 'Pohni mysi, cimz rozsvit obrazovku',
:regex       => /^pohni$/
) {
  [system("xte 'mousermove 0 1'"),
  system("xte 'mousermove 0 -1'")].join('-')
}

bot.add_command(
:syntax      => 'notify',
:description => 'Posli notifikaci na obrazovku pomoci notify-send',
:regex       => /^notify (.*)$/
) do |sender, message|
  system("notify-send '#{message} from #{sender}'")
end

bot.add_command(
:syntax      => 'exit',
:description => 'Ukonci sam sebe s exit kodem 0',
:regex       => /^exit$/
) { exit(0) }

bot.add_command(
:syntax      => 'restart',
:description => 'Ukonci sam sebe s exit kodem 1, pokud je spusten pres wrapper, restartne se',
:regex       => /^restart$/
) { exit(1) }



bot.add_command(
:syntax      => 'videjo',
:description => 'Spusti video, ktere se prave stahuje firefoxem nebo chromem z uloz.to',
:regex       => /^videjo$/
) do
  me=`whoami`
  system "cat /home/#{me}/Downloads/*part | mplayer - vo_fullscreen 1"
end

bot.add_command(
:syntax      => 'hlasitost',
:description => 'Zmeni hlasitost na uvedenou hodnotu nebo zjisti aktualni hlasitost',
:regex       => /^hlas[a-z ]*([0-9%]*)$/
) do |sender, message|
  if message==''
    `amixer get PCM`
  else
    `amixer set PCM #{message}`
  end
end


# Bring your new bot to life
bot.connect
