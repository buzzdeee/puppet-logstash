# == Define: logstash::patternfile
#
# This define allows you to transport custom pattern files to the Logstash instance
#
# All default values are defined in the logstashc::params class.
#
#
# === Parameters
#
# [*source*]
#   Puppet file resource of the pattern file ( puppet:// )
#   Value type is string
#   Default value: None
#   This variable, or the content variable is required.
#
# [*content*]
#   Contents of the puppet file.
#   Value type is string
#   Default value: None
#   This variable, or the source variable is required.
#
# [*filename*]
#   if you would like the actual file name to be different then the source file name
#   Value type is string
#   This variable is optional.
#
#
# === Examples
#
#     logstash::patternfile { 'mypattern':
#       source => 'puppet:///path/to/my/custom/pattern'
#     }
#
#     or with an other actual file name:
#
#     logstash::patternfile { 'mypattern':
#       source   => 'puppet:///path/to/my/custom/pattern_v1',
#       filename => 'custom_pattern'
#     }
#
#     another example using the content parameter:
#
#     logstash::patternfile { 'mypattern':
#       content   => "a pattern description put into the patternfile\n\tanother line",
#     }
#
#
# === Authors
#
# * Justin Lambert
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
define logstash::patternfile (
  $content = undef,
  $source = undef,
  $filename = '',
){

  if !$content and !$source {
    fail('logstash::patternfile: either "content" or "source" paramter required')
  }
  if $content and $source {
    fail('logstash::patternfile: either "content" or "source" paramter required, but not both!')
  }

  if $source {
    validate_re($source, '^puppet://', 'Source must be from a puppet fileserver (begin with puppet://)' )
  }

  $patterns_dir = "${logstash::configdir}/patterns"

  if $source {
    $filename_real = $filename ? {
      ''      => inline_template('<%= @source.split("/").last %>'),
      default => $filename
    }
  } else {
    $filename_real = $filename ? {
      ''      => $name,
      default => $filename
    }
  }

  file { "${patterns_dir}/${filename_real}":
    ensure  => 'file',
    owner   => $logstash::logstash_user,
    group   => $logstash::logstash_group,
    mode    => '0644',
    source  => $source,
    content => $content,
  }

}
