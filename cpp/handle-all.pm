use pcp3;
AddHook("DO_XIFDEF",\&do_xifdef);
AddHook("POP_PERL_BUFFER",\&pop_perl_buffer);
AddHook("HANDLE_DIRECTIVE",\&handle_directive);

sub do_xifdef {
  my ($s_start,$s_end,$kind,$conditional,$trailer,
      $skipped_text,$fSkipping,$s_branch_start) = @_;
  if ($fSkipping) {
    handle_unincluded_block($s_branch_start,
			    $skipped,$kind,$conditional);
  }
}

sub handle_unincluded_block {
  my ($s_branch_start,$s_branch_end,$skipped) = @_;
  $skipped =~ s/^\s*\#\s*include .*$//mg;
  pcp3::YYPushStackState();
  pcp3::EnterScope();
  pcp3::PushHashTab();
  pcp3::PushBuffer($skipped,$s_branch_start);
}

sub pop_perl_buffer {
  pcp3::ExitScope();
  pcp3::PopHashTab();
  pcp3::YYPopAndRestoreStackState();
}

sub handle_directive {
  $cDirectives++;
}


