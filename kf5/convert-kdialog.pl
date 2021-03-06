#!/usr/bin/perl -w

# Laurent Montel <montel@kde.org> (2014)
# convert KDialog to QDialog
# find -iname "*.cpp"|xargs kde-dev-scripts/kf5/convert-kdialog.pl

use strict;
use File::Basename;
use lib dirname($0);
use functionUtilkde;

my %dialogButtonType = (
   "Ok" => "QDialogButtonBox::Ok",
   "KDialog::Ok" => "QDialogButtonBox::Ok",
   "Cancel" => "QDialogButtonBox::Cancel",
   "KDialog::Cancel" => "QDialogButtonBox::Cancel",
   "Help" => "QDialogButtonBox::Help",
   "KDialog::Help" => "QDialogButtonBox::Help",
   "Default" => "QDialogButtonBox::RestoreDefaults",
   "KDialog::Default" => "QDialogButtonBox::RestoreDefaults",
   "Try" => "QDialogButtonBox::Retry",
   "KDialog::Try" => "QDialogButtonBox::Retry",
   "Close" => "QDialogButtonBox::Close",
   "KDialog::Close" => "QDialogButtonBox::Close",
   "No" => "QDialogButtonBox::No",
   "KDialog::No" => "QDialogButtonBox::No",
   "Yes" => "QDialogButtonBox::Yes",
   "KDialog::Yes" => "QDialogButtonBox::Yes",
   "Reset" => "QDialogButtonBox::Reset",
   "KDialog::Reset" => "QDialogButtonBox::Reset",
   "None" => "QDialogButtonBox::NoButton",
   "KDialog::None" => "QDialogButtonBox::NoButton",
   "Apply" => "QDialogButtonBox::Apply",
   "KDialog::Apply" => "QDialogButtonBox::Apply"

);

sub removePrivateVariable($)
{
   my ($localLeft) =@_;
   if ($localLeft =~ /\-\>/) {
      $localLeft =~ s/(\w+)\-\>//;
   }
   return $localLeft;
}

foreach my $file (@ARGV) {

    my $modified;
    open(my $FILE, "<", $file) or warn "We can't open file $file:$!\n";
    my %varname = ();
    my $hasUser1Button;
    my $hasUser2Button;
    my $hasUser3Button;
    my $hasOkButton;
    my $needQDialogButtonBox;
    my $needQBoxLayout;
    my $hasMainWidget;
    my $needKGuiItem;
    my @l = map {
        my $orig = $_;
        my $regexp = qr/
          ^(\s*(?:[\-\>:\w]+)?)
          setMainWidget\s*\(
          (\w+)            # (2) variable name
          \);/x; # /x Enables extended whitespace mode
        if (my ($left, $var) = $_ =~ $regexp) {
           warn "setMainWidget found :$left $var\n";
           my $localLeft = removePrivateVariable($left);

           if (defined $hasMainWidget) {
             $_ = $localLeft . "mainLayout->addWidget($var);\n";
           } else {
             $_ = $localLeft . "QVBoxLayout *mainLayout = new QVBoxLayout;\n";
             $_ .= $left . "setLayout(mainLayout);\n";
             $_ .= $localLeft . "mainLayout->addWidget($var);\n";
           }
           $varname{$var} = $var;
        }
        my $widget_regexp = qr/
           ^(\s*)            # (1) Indentation
           (.*?)             # (2) Possibly "Classname *" (the ? means non-greedy)
           (\w+)             # (3) variable name
           \s*=\s*           #     assignment
           new\s+            #     new
           (\w+)\s*          # (4) classname
           ${functionUtilkde::paren_begin}5${functionUtilkde::paren_end}  # (5) (args)
           /x; # /x Enables extended whitespace mode
        if (my ($indent, $left, $var, $classname, $args) = $_ =~ $widget_regexp) {
           # Extract last argument
           #print STDERR "left=$left var=$var classname=$classname args=$args\n";
           my $extract_parent_regexp = qr/
            ^\(
            (?:.*?)                # args before the parent (not captured, not greedy)
            \s*(\w+)\s*            # (1) parent
            (?:,\s*\"[^\"]*\"\s*)? # optional: object name
             \)$
            /x; # /x Enables extended whitespace mode
           if (my ($lastArg) = $args =~ $extract_parent_regexp) {
              print STDERR "extracted parent=" . $lastArg . "\n";
              my $mylayoutname = $varname{$lastArg};
              if (defined $mylayoutname) {
                  $_ .= $indent . "mainLayout->addWidget(" . $var . ");" . "\n";
               }
           } else {
              #warn $functionUtilkde::current_file . ":" . $functionUtilkde::current_line . ": couldn't extract last argument from " . $args . "\n";
           }
        }
        my $regexpMainWidget =qr/
         ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
         (.*?)            # (2) (the ? means non-greedy)
         \(\s*mainWidget\(\)
         \s*\);/x; # /x Enables extended whitespace mode
        if ( my ($left, $widget) = $_ =~ $regexpMainWidget) {
           my $localLeft = removePrivateVariable($left);


           if (not defined $hasMainWidget) {

             $_ = $localLeft . "QWidget *mainWidget = new QWidget(this);\n";
             $_ .= $localLeft . "QVBoxLayout *mainLayout = new QVBoxLayout;\n";
             $_ .= $left . "setLayout(mainLayout);\n";
             $_ .= $localLeft . "mainLayout->addWidget(mainWidget);\n";
             $_ .= $localLeft . "$widget(mainWidget);\n";
           } else {
             $_ = $localLeft . "$widget(mainWidget);\n";
           }
           warn "found mainWidget \n";
           $needQBoxLayout = 1;
           $hasMainWidget = 1;
        }

        my $regexpSetButtons = qr/
          ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
          setButtons\s*\(
          (.*?)            # (2) variable name
          \);/x; # /x Enables extended whitespace mode
        if (my ($left, $var) = $_ =~ $regexpSetButtons) {
           #Remove space in enum
           $var =~ s, ,,g;
           $needQDialogButtonBox = 1;
           warn "setButtons found : $var\n";
           my @listButton = split(/\|/, $var);
           my @myNewDialogButton;
           warn " list button found @listButton\n";
           if ( "Ok" ~~ @listButton || "KDialog::Ok" ~~ @listButton )  {
              push @myNewDialogButton , "QDialogButtonBox::Ok";
              $hasOkButton = 1;
           }
           if ( "Cancel" ~~ @listButton || "KDialog::Cancel" ~~ @listButton)  {
              push @myNewDialogButton , "QDialogButtonBox::Cancel";
           }
           if ( "Help" ~~ @listButton || "KDialog::Help" ~~ @listButton)  {
              push @myNewDialogButton , "QDialogButtonBox::Help";
           }
           if ( "Default" ~~ @listButton || "KDialog::Default" ~~ @listButton)  {
              push @myNewDialogButton , "QDialogButtonBox::RestoreDefaults";
           }
           if ( "Try" ~~ @listButton || "KDialog::Try" ~~ @listButton)  {
              push @myNewDialogButton , "QDialogButtonBox::Retry";
           }
           if ( "Close" ~~ @listButton || "KDialog::Close" ~~ @listButton)  {
              push @myNewDialogButton , "QDialogButtonBox::Close";
           }
           if ( "No" ~~ @listButton || "KDialog::No" ~~ @listButton)  {
              push @myNewDialogButton , "QDialogButtonBox::No";
           }
           if ( "Yes" ~~ @listButton || "KDialog::Yes" ~~ @listButton)  {
              push @myNewDialogButton , "QDialogButtonBox::Yes";
           }
           if ( "Apply" ~~ @listButton || "KDialog::Apply" ~~ @listButton)  {
              push @myNewDialogButton , "QDialogButtonBox::Apply";
           }
           if ( "Reset" ~~ @listButton || "KDialog::Reset" ~~ @listButton)  {
              push @myNewDialogButton , "QDialogButtonBox::Reset";
           }
           if ( "Details" ~~ @listButton || "KDialog::Details" ~~ @listButton)  {
              warn "DETAILS is not implemented. Need to reimplement it\n";
           }
           if ( "None" ~~ @listButton || "KDialog::None" ~~ @listButton)  {
              push @myNewDialogButton , "QDialogButtonBox::NoButton";
           }
           if ( "User1" ~~ @listButton || "KDialog::User1" ~~ @listButton)  {
              $hasUser1Button = 1;
           }
           if ( "User2" ~~ @listButton || "KDialog::User2" ~~ @listButton)  {
              $hasUser2Button = 1;
           }
           if ( "User3" ~~ @listButton || "KDialog::User3" ~~ @listButton)  {
              $hasUser3Button = 1;
           }
           my $resultList = join('|', @myNewDialogButton);
           my $localLeft = removePrivateVariable($left);

           $_ = $localLeft . "QDialogButtonBox *buttonBox = new QDialogButtonBox($resultList);\n";
           if (not defined $hasMainWidget) {
             $_ .= $localLeft . "QWidget *mainWidget = new QWidget(this);\n";
             $_ .= $localLeft . "QVBoxLayout *mainLayout = new QVBoxLayout;\n";
             $_ .= $left . "setLayout(mainLayout);\n";
             $_ .= $localLeft . "mainLayout->addWidget(mainWidget);\n";
             #$_ .= $left . "$widget(mainWidget);\n";
             $hasMainWidget = 1;
             $needQBoxLayout = 1;
             $needQDialogButtonBox = 1;
           }

           if (defined $hasOkButton) {
              $_ .= $localLeft . "QPushButton *okButton = buttonBox->button(QDialogButtonBox::Ok);\n";
              $_ .= $localLeft . "okButton->setDefault(true);\n";
              $_ .= $localLeft . "okButton->setShortcut(Qt::CTRL | Qt::Key_Return);\n";
           }

           if (defined $hasUser1Button) {
              $_ .= $localLeft . "QPushButton *user1Button = new QPushButton;\n";
              $_ .= $localLeft . "buttonBox->addButton(user1Button, QDialogButtonBox::ActionRole);\n";
           }
           if (defined $hasUser2Button) {
              $_ .= $localLeft . "QPushButton *user2Button = new QPushButton;\n";
              $_ .= $localLeft . "buttonBox->addButton(user2Button, QDialogButtonBox::ActionRole);\n";
           }
           if (defined $hasUser3Button) {
              $_ .= $localLeft . "QPushButton *user3Button = new QPushButton;\n";
              $_ .= $localLeft . "buttonBox->addButton(user3Button, QDialogButtonBox::ActionRole);\n";
           }

           $_ .= $left . "connect(buttonBox, SIGNAL(accepted()), this, SLOT(accept()));\n";
           $_ .= $left . "connect(buttonBox, SIGNAL(rejected()), this, SLOT(reject()));\n";
           $_ .= $localLeft . "//PORTING SCRIPT: WARNING mainLayout->addWidget(buttonBox) must be last item in layout. Please move it.\n";
           $_ .= $localLeft . "mainLayout->addWidget(buttonBox);\n";

           warn "WARNING we can't move this code at the end of constructor. Need to move it !!!!\n";
        }
        if (/defaultClicked\(\)/) {
             s/connect\s*\(\s*this,/connect(buttonBox->button(QDialogButtonBox::RestoreDefaults),/;
             s/defaultClicked\(\)/clicked()/;
        }
        if (/okClicked\(\)/) {
             s/connect\s*\(\s*this,/connect(okButton,/;
             s/SIGNAL\s*\(\s*okClicked\(\)/SIGNAL\(clicked()/;
        }
        if (/applyClicked\(\)/) {
             s/connect\s*\(\s*this,/connect(buttonBox->button(QDialogButtonBox::Apply),/;
             s/SIGNAL\s*\(\s*applyClicked\(\)/SIGNAL\(clicked()/;
        }

        if (/closeClicked\(\)/) {
             s/connect\s*\(\s*this,/connect(buttonBox->button(QDialogButtonBox::Close),/;
             s/SIGNAL\s*\(\s*closeClicked\(\)/SIGNAL\(clicked()/;
        }

        if (/cancelClicked\(\)/) {
             s/connect\s*\(\s*this,/connect(buttonBox->button(QDialogButtonBox::Cancel),/;
             s/SIGNAL\s*\(\s*cancelClicked\(\)/SIGNAL\(clicked()/;
        }
        if (/user1Clicked\(\)/) {
             s/connect\s*\(\s*this,/connect(user1Button,/;
             s/user1Clicked\(\)/clicked()/;
        }
        if (/user2Clicked\(\)/) {
             s/connect\s*\(\s*this,/connect(user2Button,/;
             s/SIGNAL\s*\(\s*user2Clicked\(\)/SIGNAL\(clicked()/;
        }
        if (/user3Clicked\(\)/) {
             s/connect\s*\(\s*this,/connect(user3Button,/;
             s/SIGNAL\s*\(\s*user3Clicked\(\)/SIGNAL\(clicked()/;
        }
        if (/resetClicked\(\)/) {
             s/connect\s*\(\s*this,/connect(buttonBox->button(QDialogButtonBox::Reset),/;
             s/SIGNAL\s*\(\s*resetClicked\(\)/SIGNAL\(clicked()/;
        }

        my $regexEnableButton = qr/
          ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
          enableButton
          ${functionUtilkde::paren_begin}2${functionUtilkde::paren_end}  # (2) (args)
          /x; # /x Enables extended whitespace mode
        if (my ($left, $args) = $_ =~ $regexEnableButton) {
           warn "found enableButton $args\n";
           my $localLeft = removePrivateVariable($left);

           my $extract_args_regexp = qr/
                                 ^\(([^,]*)         # button
                                 ,\s*([^,]*)        # state
                                 (.*)$              # after
                                 /x;

           if ( my ($defaultButtonType, $state) = $args =~  $extract_args_regexp ) {
              $defaultButtonType =~ s, ,,g;
              $defaultButtonType =~ s,^KDialog::,,;
              $state =~ s, ,,g;
              $state =~ s,\),,g;
             if (defined $dialogButtonType{$defaultButtonType}) {
                if ( $defaultButtonType eq "Ok") {
                   $_ = $localLeft . "okButton->setEnabled($state);\n";
                } else {
                   $_ = $localLeft . "buttonBox->button($dialogButtonType{$defaultButtonType})->setEnabled($state);\n";
                }
             } else {
                if ($defaultButtonType eq "User1") {
                   $_ = $localLeft . "user1Button\->setEnabled($state);\n";
                } elsif ($defaultButtonType eq "User2") {
                   $_ = $localLeft . "user2Button\->setEnabled($state);\n";
                } elsif ($defaultButtonType eq "User3") {
                   $_ = $localLeft . "user3Button\->setEnabled($state);\n";
                } else {
                   warn "Enable button: unknown or not supported \'$defaultButtonType\'\n";
                }
             }
             warn "Found enabled button \'$defaultButtonType\', state \'$state\'\n";
           }
        }

        my $regexDefaultButton = qr/
                               ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
                               setDefaultButton\s*\(
                               (.*)             # (2) button type
                               \);/x; # /x Enables extended whitespace mode
        if ( my ($left, $defaultButtonType) = $_ =~ $regexDefaultButton ) {
           warn "Found default button type : $defaultButtonType\n";
           $defaultButtonType =~ s, ,,g;
           my $localLeft = removePrivateVariable($left);

           if (defined $dialogButtonType{$defaultButtonType}) {
              if ( $defaultButtonType eq "Ok") {
                 $_ = $localLeft . "okButton->setDefault(true);\n";
              } else {
                 $_ = $localLeft . "buttonBox->button($dialogButtonType{$defaultButtonType})->setDefault(true);\n";
              }
           } else {
              if ($defaultButtonType eq "User1") {
                 $_ = $localLeft . "user1Button\->setDefault(true);\n";
              } elsif ($defaultButtonType eq "User2") {
                 $_ = $localLeft . "user2Button\->setDefault(true);\n";
              } elsif ($defaultButtonType eq "User3") {
                 $_ = $localLeft . "user3Button\->setDefault(true);\n";
              } elsif ($defaultButtonType eq "NoButton") {
                 $_ = "";
              } else {
                warn "Default button type unknown or not supported \'$defaultButtonType\'\n";
              }
           }
        }

        my $regexButtonFocus = qr/
                               ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
                               setButtonFocus\s*\(
                               (.*)
                               \s*\);/x; # /x Enables extended whitespace mode
        if ( my ($left, $defaultButtonType) = $_ =~ $regexButtonFocus ) {
           $defaultButtonType =~ s, ,,g;
           my $localLeft = removePrivateVariable($left);

           warn "Found default button focus : $defaultButtonType\n";
           if (defined $dialogButtonType{$defaultButtonType}) {
              if ( $defaultButtonType eq "Ok") {
                 $_ = $localLeft . "okButton->setFocus();\n";
              } else {
                 $_ = $localLeft . "buttonBox->button($dialogButtonType{$defaultButtonType})->setFocus();\n";
              }
           } else {
              if ($defaultButtonType eq "User1") {
                 $_ = $localLeft . "user1Button\->setFocus();\n";
              } elsif ($defaultButtonType eq "User2") {
                 $_ = $localLeft . "user2Button\->setFocus();\n";
              } elsif ($defaultButtonType eq "User3") {
                 $_ = $localLeft . "user3Button\->setFocus();\n";
              } else {
                warn "Default button focus: unknown or not supported \'$defaultButtonType\'\n";
              }
           }
        }


        my $regexSetButtonText = qr/
          ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
          setButtonText
          ${functionUtilkde::paren_begin}2${functionUtilkde::paren_end}  # (2) (args)
          /x; # /x Enables extended whitespace mode
        if (my ($left, $args) = $_ =~ $regexSetButtonText) {
           warn "found setButtonText $args\n";
           my $localLeft = removePrivateVariable($left);

           my $extract_args_regexp = qr/
                                 ^\(([^,]*)           # button
                                 ,\s*([^,]*)        # state
                                 (.*)$              # after
                                 /x;
           if ( my ($defaultButtonType, $text) = $args =~  $extract_args_regexp ) {
              $defaultButtonType =~ s, ,,g;
              $defaultButtonType =~ s,^KDialog::,,;
              #$text =~ s, ,,g;
              $text =~ s,\),,g;
              if (defined $dialogButtonType{$defaultButtonType}) {
                 if ( $defaultButtonType eq "Ok") {
                    $_ = $localLeft . "okButton->setText($text));\n";
                 } else {
                    $_ = $localLeft . "buttonBox->button($dialogButtonType{$defaultButtonType})->setText($text));\n";
                }
              } else {
                 if ($defaultButtonType eq "User1") {
                    $_ = $localLeft . "user1Button\->setText($text));\n";
                 } elsif ($defaultButtonType eq "User2") {
                    $_ = $localLeft . "user2Button\->setText($text));\n";
                 } elsif ($defaultButtonType eq "User3") {
                    $_ = $localLeft . "user3Button\->setText($text));\n";
                 } else {
                     warn "Set button Text: unknown or not supported \'$defaultButtonType\'\n";
                 }
              }
           }
        }

        my $regexSetButtonMenu = qr/
          ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
          setButtonMenu
          ${functionUtilkde::paren_begin}2${functionUtilkde::paren_end}  # (2) (args)
          /x; # /x Enables extended whitespace mode
        if (my ($left, $args) = $_ =~ $regexSetButtonMenu) {
           warn "found setButtonMenu $args\n";
           my $localLeft = removePrivateVariable($left);

           my $extract_args_regexp = qr/
                                 ^\(([^,]*)           # button
                                 ,\s*([^,]*)        # state
                                 (.*)$              # after
                                 /x;
           if ( my ($button, $menuName) = $args =~  $extract_args_regexp ) {
              $button =~ s, ,,g;
              $menuName =~ s, ,,g;
              $menuName =~ s,\),,g;
              warn "Found setButtonMenu: \'$button\', menu variable \'$menuName\'\n";
              if (defined $dialogButtonType{$button}) {
                 if ( $button eq "Ok" || $button eq "KDialog::Ok") {
                    $_ = $localLeft . "okButton->setMenu($menuName);\n";
                 } else {
                    $_ = $localLeft . "buttonBox->button($dialogButtonType{$button})->setMenu($menuName);\n";
                }
              } else {
                 if ($button eq "User1") {
                    $_ = $localLeft . "user1Button\->setMenu($menuName);\n";
                 } elsif ($button eq "User2") {
                    $_ = $localLeft . "user2Button\->setMenu($menuName);\n";
                 } elsif ($button eq "User3") {
                    $_ = $localLeft . "user3Button\->setMenu($menuName);\n";
                 } else {
                     warn "Set Button Menu: unknown or not supported \'$button\'\n";
                 }
              }
           }
        }
        my $regexSetButtonIcon = qr/
          ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
          setButtonIcon
          ${functionUtilkde::paren_begin}2${functionUtilkde::paren_end}  # (2) (args)
          /x; # /x Enables extended whitespace mode
        if (my ($left, $args) = $_ =~ $regexSetButtonIcon) {
           warn "found setButtonIcon $args\n";
           my $localLeft = removePrivateVariable($left);

           my $extract_args_regexp = qr/
                                 ^\(([^,]*)           # button
                                 ,\s*([^,]*)        # state
                                 (.*)$              # after
                                 /x;
           if ( my ($button, $menuName) = $args =~  $extract_args_regexp ) {
              $button =~ s, ,,g;
              $menuName =~ s, ,,g;
              $menuName =~ s,\),,g;
              warn "Found setButtonIcon: \'$button\', menu variable \'$menuName\'\n";
              if (defined $dialogButtonType{$button}) {
                 if ( $button eq "Ok" || $button eq "KDialog::Ok") {
                    $_ = $localLeft . "okButton->setIcon($menuName);\n";
                 } else {
                    $_ = $localLeft . "buttonBox->button($dialogButtonType{$button})->setIcon($menuName);\n";
                }
              } else {
                 if ($button eq "User1") {
                    $_ = $localLeft . "user1Button\->setIcon($menuName);\n";
                 } elsif ($button eq "User2") {
                    $_ = $localLeft . "user2Button\->setIcon($menuName);\n";
                 } elsif ($button eq "User3") {
                    $_ = $localLeft . "user3Button\->setIcon($menuName);\n";
                 } else {
                     warn "Set Button Icon: unknown or not supported \'$button\'\n";
                 }
              }
           }
        }


        my $regexSetButtonWhatsThis = qr/
          ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
          setButtonWhatsThis
          ${functionUtilkde::paren_begin}2${functionUtilkde::paren_end}  # (2) (args)
          /x; # /x Enables extended whitespace mode
        if (my ($left, $args) = $_ =~ $regexSetButtonWhatsThis) {
           warn "found setButtonWhatsThis $args\n";
           my $extract_args_regexp = qr/
                                 ^\(([^,]*)           # button
                                 ,\s*([^,]*)        # i18n
                                 (.*)$              # after
                                 /x;
           my $localLeft = removePrivateVariable($left);

           if ( my ($button, $i18n) = $args =~  $extract_args_regexp ) {
              $button =~ s, ,,g;
              $i18n =~ s,\),,g;
              $button =~ s,^KDialog::,,;

              warn "Found setButtonWhatsThis: \'$button\', i18n \'$i18n\'\n";
              if (defined $dialogButtonType{$button}) {
                 if ( $button eq "Ok" || $button eq "KDialog::Ok") {
                    $_ = $localLeft . "okButton->setWhatsThis($i18n));\n";
                 } else {
                    $_ = $localLeft . "buttonBox->button($dialogButtonType{$button})->setWhatsThis($i18n));\n";
                }
              } else {
                 if ($button eq "User1") {
                    $_ = $localLeft . "user1Button->setWhatsThis($i18n));\n";
                 } elsif ($button eq "User2") {
                    $_ = $localLeft . "user2Button->setWhatsThis($i18n));\n";
                 } elsif ($button eq "User3") {
                    $_ = $localLeft . "user3Button->setWhatsThis($i18n));\n";
                 } else {
                     warn "setButtonWhatsThis: unknown or not supported \'$button\'\n";
                 }
              }
           }
        }



        my $regexSetButtonToolTip = qr/
          ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
          setButtonToolTip
          ${functionUtilkde::paren_begin}2${functionUtilkde::paren_end}  # (2) (args)
          /x; # /x Enables extended whitespace mode
        if (my ($left, $args) = $_ =~ $regexSetButtonToolTip) {
           warn "found setButtonToolTip $args\n";
           my $extract_args_regexp = qr/
                                 ^\(([^,]*)           # button
                                 ,\s*([^,]*)        # i18n
                                 (.*)$              # after
                                 /x;
           my $localLeft = removePrivateVariable($left);
           if ( my ($button, $i18n) = $args =~  $extract_args_regexp ) {
              $button =~ s, ,,g;
              $i18n =~ s,\),,g;
              $button =~ s,^KDialog::,,;

              warn "Found setButtonToolTip: \'$button\', i18n \'$i18n\'\n";
              if (defined $dialogButtonType{$button}) {
                 if ( $button eq "Ok" || $button eq "KDialog::Ok") {
                    $_ = $localLeft . "okButton->setToolTip($i18n));\n";
                 } else {
                    $_ = $localLeft . "buttonBox->button($dialogButtonType{$button})->setToolTip($i18n));\n";
                }
              } else {
                 if ($button eq "User1") {
                    $_ = $localLeft . "user1Button->setToolTip($i18n));\n";
                 } elsif ($button eq "User2") {
                    $_ = $localLeft . "user2Button->setToolTip($i18n));\n";
                 } elsif ($button eq "User3") {
                    $_ = $localLeft . "user3Button->setToolTip($i18n));\n";
                 } else {
                     warn "setButtonToolTip: unknown or not supported \'$button\'\n";
                 }
              }
           }
        }


        my $regexSetButtonGuiItem = qr/
          ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
          setButtonGuiItem
          ${functionUtilkde::paren_begin}2${functionUtilkde::paren_end}  # (2) (args)
          /x; # /x Enables extended whitespace mode
        if (my ($left, $args) = $_ =~ $regexSetButtonGuiItem) {
           warn "found setButtonGuiItem $args\n";
           my $extract_args_regexp = qr/
                                 ^\(([^,]*)           # button
                                 ,\s*([^,]*)        # state
                                 (.*)$              # after
                                 /x;
           my $localLeft = removePrivateVariable($left);

           if ( my ($button, $menuName) = $args =~  $extract_args_regexp ) {
              $button =~ s, ,,g;
              #$menuName =~ s, ,,g;
              $menuName =~ s,\),,g;
              $button =~ s,^KDialog::,,;

              $needKGuiItem = 1;
              warn "Found setButtonGuiItem: \'$button\', menu variable \'$menuName\'\n";
              if (defined $dialogButtonType{$button}) {
                 if ( $button eq "Ok" || $button eq "KDialog::Ok") {
                    $_ = $localLeft . "KGuiItem::assign(okButton, $menuName));\n";
                 } else {
                    $_ = $localLeft . "KGuiItem::assign(buttonBox->button($dialogButtonType{$button}), $menuName));\n";
                }
              } else {
                 if ($button eq "User1") {
                    $_ = $localLeft . "KGuiItem::assign(user1Button, $menuName));\n";
                 } elsif ($button eq "User2") {
                    $_ = $localLeft . "KGuiItem::assign(user2Button, $menuName));\n";
                 } elsif ($button eq "User3") {
                    $_ = $localLeft . "KGuiItem::assign(user3Button, $menuName));\n";
                 } else {
                     warn "Set Button Gui Item: unknown or not supported \'$button\'\n";
                 }
              }
           }
        }


        my $regexShowButton = qr/
          ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
          showButton
          ${functionUtilkde::paren_begin}2${functionUtilkde::paren_end}  # (2) (args)
          /x; # /x Enables extended whitespace mode
        if (my ($left, $args) = $_ =~ $regexShowButton) {
           warn "found showButton $args\n";
           my $extract_args_regexp = qr/
                                 ^\(([^,]*)           # button
                                 ,\s*([^,]*)        # state
                                 (.*)$              # after
                                 /x;
           my $localLeft = removePrivateVariable($left);

           if ( my ($defaultButtonType, $state) = $args =~  $extract_args_regexp ) {
              $defaultButtonType =~ s, ,,g;
              $state =~ s, ,,g;
              $state =~ s,\),,g;
             if (defined $dialogButtonType{$defaultButtonType}) {
                if ( $defaultButtonType eq "Ok") {
                   $_ = $localLeft . "okButton->setVisible($state);\n";
                } else {
                   $_ = $localLeft . "buttonBox->button($dialogButtonType{$defaultButtonType})->setVisible($state);\n";
                }
             } else {
                if ($defaultButtonType eq "User1") {
                   $_ = $localLeft . "user1Button\->setVisible($state);\n";
                } elsif ($defaultButtonType eq "User2") {
                   $_ = $localLeft . "user2Button\->setVisible($state);\n";
                } elsif ($defaultButtonType eq "User3") {
                   $_ = $localLeft . "user3Button\->setVisible($state);\n";
                } else {
                   warn "Show button: unknown or not supported \'$defaultButtonType\'\n";
                }
             }
             warn "Found show button \'$defaultButtonType\', state \'$state\'\n";
           }
        }


        if (/KDialog::spacingHint/) {
           $_ = "//TODO PORT QT5 " .  $_;
        }
        if (/KDialog::marginHint/) {
           $_ = "//TODO PORT QT5 " .  $_;
        }

        my $regexSetEscapeButton = qr/
          (.*)           # (1) Indentation
          setEscapeButton\s*\(\s*([:\w]+)\s*\)   # (2) (args)
          (.*)                            # (3) after
          /x; # /x Enables extended whitespace mode
        if (my ($left, $button, $after) = $_ =~ $regexSetEscapeButton) {
           $button =~ s, ,,g;
           $button =~ s,^KDialog::,,;
           if (defined $dialogButtonType{$button}) {
              if ( $button eq "Ok") {
                 $_ = $left . "okButton->setShortcut(Qt::Key_Escape);\n";
              } else {
                 $_ = $left . "buttonBox->button($dialogButtonType{$button})->setShortcut(Qt::Key_Escape)" . $after . "\n";
              }
             } else {
                if ($button eq "User1") {
                   $_ = $left . "user1Button\->setShortcut(Qt::Key_Escape)" . $after . "\n";
                } elsif ($button eq "User2") {
                   $_ = $left . "user2Button\->setShortcut(Qt::Key_Escape)" . $after . "\n";
                } elsif ($button eq "User3") {
                   $_ = $left . "user3Button\->setShortcut(Qt::Key_Escape)" . $after . "\n";
                } else {
                   warn "Show button: unknown or not supported \'$button\'\n";
                }
             }

        }


        # if ( isButtonEnabled( KDialog::Apply ) ) {

        my $regexIsButtonEnabled = qr/
          (.*)           # (1) Indentation
          isButtonEnabled\s*\(\s*([:\w]+)\s*\)   # (2) (args)
          (.*)                            # (3) after
          /x; # /x Enables extended whitespace mode
        if (my ($left, $button, $after) = $_ =~ $regexIsButtonEnabled) {
           $button =~ s, ,,g;
           $button =~ s,^KDialog::,,;
           if (defined $dialogButtonType{$button}) {
              if ( $button eq "Ok") {
                 $_ = $left . "okButton->isEnabled()" . $after . "\n";
              } else {
                 $_ = $left . "buttonBox->button($dialogButtonType{$button})->isEnabled()" . $after . "\n";
              }
             } else {
                if ($button eq "User1") {
                   $_ = $left . "user1Button\->isEnabled()" . $after . "\n";
                } elsif ($button eq "User2") {
                   $_ = $left . "user2Button\->isEnabled()" . $after . "\n";
                } elsif ($button eq "User3") {
                   $_ = $left . "user3Button\->isEnabled()" . $after . "\n";
                } else {
                   warn "Show button: unknown or not supported \'$button\'\n";
                }
             }

        }

        if (/\bsetMainWidget\s*\(\s*(\w+)\s*\)/) {
           # remove setMainWidget doesn't exist now.
           my $var = $1;
           $_ = "//PORTING: Verify that widget was added to mainLayout: " . $_;
           $_ .= "// Add mainLayout->addWidget($var); if necessary\n";
        }
        if (/\bshowButtonSeparator\b/) {
           # remove showButtonSeparator doesn't exist now.
           $_ = "";
        }

        my $regexButton = qr/
          ^(\s*(?:[\-\>:\w]+)?)           # (1) Indentation
          button
          ${functionUtilkde::paren_begin}2${functionUtilkde::paren_end}  # (2) (args)
          /x; # /x Enables extended whitespace mode
        if (my ($left, $button) = $_ =~ $regexButton) {
           $button =~ s/\(//;
           $button =~ s/\)//;
           $button =~ s, ,,g;
           $button =~ s,^KDialog::,,;
           my $localLeft = removePrivateVariable($left);

           if (defined $dialogButtonType{$button}) {
              if ( $button eq "Ok" || $button eq "KDialog::Ok") {
                 s/button\s*\(\s*KDialog::Ok\s*\)/okButton/;
                 s/button\s*\(\s*Ok\s*\)/okButton/;
              } else {
                 s/button\s*\(\s*$button\s*\)/buttonBox->button($dialogButtonType{$button})/;
              }
           } else {
              if ($button eq "User1") {
                 s/button\s*\(\s*KDialog::User1\s*\)/user1Button/;
                 s/button\s*\(\s*User1\s*\)/user1Button/;

              } elsif ($button eq "User2") {
                 s/button\s*\(\s*KDialog::User2\s*\)/user2Button/;
                 s/button\s*\(\s*User2\s*\)/user2Button/;
              } elsif ($button eq "User3") {
                 s/button\s*\(\s*KDialog::User3\s*\)/user3Button/;
                 s/button\s*\(\s*User3\s*\)/user3Button/;
              } else {
                 warn "button(...): unknown or not supported \'$button\'\n";
              }
           }

           warn "Found button(...) with argument $button\n";
        }
        if (/::slotButtonClicked\b/) {
           $_ = "//Adapt code and connect okbutton or other to new slot. It doesn't exist in qdialog\n" . $_;
           warn "$file connect okbutton and other to new slot here\n";
        }

        s/\bsetCaption\b/setWindowTitle/;
        s/\benableButtonOk\b/okButton->setEnabled/;
        s/\benableButtonApply\b/buttonBox->button(QDialogButtonBox::Apply)->setEnabled/;
        s/\bKDialog\b/QDialog/g;
        s/\<KDialog\b\>/\<QDialog>/ if (/#include/);
        s/\<kdialog.h\>/\<QDialog>/ if (/#include/);
        s/\bsetInitialSize\b/resize/;
        s/button\s*\(\s*User2\s*\)/user2Button/;
        s/button\s*\(\s*User1\s*\)/user1Button/;
        s/button\s*\(\s*User3\s*\)/user3Button/;

        $modified ||= $orig ne $_;
        $_;
    } <$FILE>;

    if ($modified) {
        open (my $OUT, ">", $file);
        print $OUT @l;
        close ($OUT);
        # Need to add KConfigGroup because it was added by kdialog before
        if ($file =~ /\.cpp$/) {
            functionUtilkde::addIncludeInFile($file, "KConfigGroup");
        }

        if (defined $needQDialogButtonBox) {
           functionUtilkde::addIncludeInFile($file, "QDialogButtonBox");
           functionUtilkde::addIncludeInFile($file, "QPushButton");
        } else {
           if ( $file =~ /\.cpp$/) {
             warn "WARNING: check if you are using the default buttons Ok|Cancel without calling setButtons\n";
             warn "In this case, add this code:\n";
             warn "#include <QDialogButtonBox>\n";
             warn "#include <QPushButton>\n";
             warn "QDialogButtonBox *buttonBox = new QDialogButtonBox(QDialogButtonBox::Ok|QDialogButtonBox::Cancel);\n";
             warn "QPushButton *okButton = buttonBox->button(QDialogButtonBox::Ok);\n";
             warn "okButton->setDefault(true);\n";
             warn "okButton->setShortcut(Qt::CTRL | Qt::Key_Return);\n";
             warn "connect(buttonBox, SIGNAL(accepted()), this, SLOT(accept()));\n";
             warn "connect(buttonBox, SIGNAL(rejected()), this, SLOT(reject()));\n";
             warn "mainLayout->addWidget(buttonBox);\n";
           }
        }
        if (defined $needKGuiItem) {
           functionUtilkde::addIncludeInFile($file, "KGuiItem");
        }
        if (defined $needQBoxLayout) {
           functionUtilkde::addIncludeInFile($file, "QVBoxLayout");
        }
    }
}

functionUtilkde::diffFile( "@ARGV" );
