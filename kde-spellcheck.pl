#!/usr/bin/perl -w

use POSIX;
use strict;

my %fix = (
         "aasumes" => "assumes",
	 "abailable" => "available",
         "acces" => "access",
         "accesible" => "accessible",
	 "accesing" => "accessing",
	 "accomodate" => "accommodate",
	 "acommodate" => "accommodate",
	 "Acknowlege" => "Acknowledge",
	 "acknoledged" => "acknowledged",
	 "acknowledgement" => "acknowledgment",
	 "Acknowledgements" => "Acknowledgments",
	 "aquire" => "acquire",
	 "accross" => "across",
	 "actons" => "actions",
	 "adapater" => "adapter",
	 "adatper" => "adapter",
	 "additionnal" => "additional",
	 "Addtional" => "Additional",
	 "adress" => "address",
         "adresses" => "addresses",
	 "adddress" => "address",
	 "Adress" => "Address",
	 "Agressive" => "Aggressive",
	 "agressively" => "aggressively",
	 "alligned" => "aligned",
	 "alignement" => "alignment",
	 "allready" => "already",
         "alrady" => "already",
	 "Allways" => "Always",
	 "alook" => "a look",
	 "alows" => "allows",
	 "allways" => "always",
	 "ammount" => "amount",
	 "analogue" => "analog",
	 "analyse" => "analyze",
	 "analyses" => "analyzes",
	 "angainst" => "against",
         "anwsers" => "answers",
         "appers" => "appears",
         "appearence" => "appearance",
         "appeareance" => "appearance",
         "applicaiton" => "application",
         "aplication" => "application",
         "appplication" => "application",
	 "appliction" => "application",
	 "appropiate" => "appropriate",
	 "approriate" => "appropriate",
	 "apropriate" => "appropriate",
         "aribrary" => "arbitrary",
	 "arbitarily" => "arbitrarily",
	 "aribtrarily" => "arbitrarily",
	 "Arbitary" => "Arbitrary",
	 "aribtrary" => "arbitrary",
	 "arround" => "around",
	 "asssembler" => "assembler",
	 "assosciated" => "associated",
	 "assosiated" => "associated",
	 "asume" => "assume",
	 "asyncronous" => "asynchronous",
	 "atleast" => "at least",
         "aticles" => "articles",
	 "atomicly" => "atomically",
	 "Auxilary" => "Auxiliary",
         "automaticaly" => "automatically",
         "Automaticaly" => "Automatically",
	 "availble" => "available",
	 "avaible" => "available",
	 "availible" => "available",
	 "avaliable" => "available",
	 "approciated" => "appreciated",
	 "Basicly" => "Basically",
	 "basicly" => "basically",
	 "becuase" => "because",
         "beautifull" => "beautiful",
         "befor" => "before",
	 "beggining" => "beginning",
	 "behaviour" => "behavior",
	 "beeing" => "being",
	 "beteen" => "between",
         "bruning" => "burning",
	 "boundries" => "boundaries",
	 "boundry" => "boundary",
	 "cancelation" => "cancellation",
         "cancelled" => "canceled",
	 "capabilites" => "capabilities",
	 "cacheing" => "caching",
	 "catalogue" => "catalog",
	 "catched" => "caught",
         "ceneration" => "generation",
	 "changable" => "changeable",
	 "charater" => "character",
         "caracters" => "characters",
	 "centre" => "center",
	 "Centre" => "Center",
	 "Characteres" => "Characters",
	 "choosed" => "chose",
	 "choosen" => "chosen",
	 "Cristian" => "Christian",
         "chosing" => "choosing",
	 "cirumstances" => "circumstances",
         "coloum" => "column",
	 "colour" => "color",
	 "colours" => "colors",
         "coloumn" => "column",
         "cloumn" => "column",
	 "comming" => "coming",
	 "comamnd" => "command",
	 "commense" => "commence",
	 "commited" => "committed",
	 "commuication" => "communication",
	 "comparision" => "comparison",
	 "comparisions" => "comparisons",
	 "compability" => "compatibility",
	 "Compatability" => "Compatibility",
	 "compatibilty" => "compatibility",
	 "compatiblity" => "compatibility",
	 "completly" => "completely",
         "compleion" => "completion",
	 "complient" => "compliant",
	 "comsumer" => "consumer",
	 "concurent" => "concurrent",
	 "configration" => "configuration",
	 "consequtive" => "consecutive",
	 "conver" => "convert",
	 "konstants" => "constants",
         "connent" => "connect",
         "connnection" => "connection",
	 "contigious" => "contiguous",
	 "contingous" => "contiguous",
	 "Continous" => "Continuous",
	 "continous" => "continuous",
	 "controll" => "control",
	 "Contorll" => "Control",
	 "contoller" => "controller",
	 "controler" => "controller",
	 "controling" => "controlling",
	 "Coverted" => "Converted",
	 "coresponding" => "corresponding",
         "coursor" => "cursor",
	 "curteousy" => "courtesy",
	 "customisation" => "customization",
	 "cutt" => "cut",
	 "Cutt" => "Cut",
	 "deactive" => "deactivate",
	 "Debuging" => "Debugging",
	 "Demonsrative" => "Demonstrative",
	 "debuging" => "debugging",
	 "defered" => "deferred",
	 "defintions" => "definitions",
	 "dependend" => "dependent",
	 "depricated" => "deprecated",
	 "dialogue" => "dialog",
         "disappers" => "disappears",
         "discription" => "description",
	 "distrubutor" => "distributor",
	 "decriptor" => "descriptor",
	 "desciptor" => "descriptor",
	 "desination" => "destination",
	 "destiantion" => "destination",
	 "developped" => "developed",
	 "didnt" => "didn't",
	 "differenciate" => "differentiate",
         "diable" => "disable",
	 "digitised" => "digitized",
         "dirctory" => "directory",
	 "desiabled" => "disabled",
         "disactivate" => "deactivate",
	 "discpline" => "discipline",
	 "discontigous" => "discontiguous",
	 "distingush" => "distinguish",
	 "devide" => "divide",
	 "divizor" => "divisor",
	 "docucument" => "document",
	 "Donot" => "Do not",
	 "donnot" => "do not",
	 "doens't" => "doesn't",
	 "doesnt" => "doesn't",
	 "dont't" => "don't",
	 "dont" => "don't",
	 "dreamt" => "dreamed",
	 "draging" => "dragging",
	 "dynamicly" => "dynamically",
	 "efficent" => "efficient",
	 "efficently" => "efficiently",
	 "imperical" => "empirical",
	 "enhandcements" => "enhancements",
	 "enought" => "enough",
	 "entrys" => "entries",
	 "enviroment" => "environment",
	 "environent" => "environment",
	 "equiped" => "equipped",
	 "errror" => "error",
         "errorous" => "erroneous",
	 "Evalute" => "Evaluate",
	 "everytime" => "every time",
         "eample" => "example",
         "exapmle" => "example",
	 "execess" => "excess",
	 "execeeded" => "exceeded",
	 "executeble" => "executable",
	 "exection" => "execution",
	 "existance" => "existence",
	 "explicitely" => "explicitly",
	 "explicity" => "explicitly",
	 "extented" => "extended",
	 "extention" => "extension",
	 "extentions" => "extensions",
	 "Extention" => "Extension",
	 "fabilous" => "fabulous",
	 "favour" => "favor",
	 "favours" => "favors",
	 "favourable" => "favorable",
	 "favourite" => "favorite",
	 "fastes" => "fastest",
	 "firware" => "firmware",
	 "fixiating" => "fixating",
	 "fixiated" => "fixated",
	 "fixiate" => "fixate",
	 "foward" => "forward",
	 "fucntion" => "function",
	 "fuction" => "function",
	 "fuctions" => "functions",
	 "fulfilling" => "fulfiling",
	 "funcion" => "function",
	 "funciton" => "function",
	 "functin" => "function",
	 "funtion" => "function",
         "funtional" => "functional",
	 "funtions" => "functions",
	 "furthur" => "further",
         "gernerated" => "generated",
	 "guarenteed" => "guaranteed",
	 "handeling" => "handling",
	 "harware" => "hardware",
	 "hasnt" => "hasn't",
	 "havn't" => "haven't",
         "heigt" => "height",
         "heigth" => "height",
         "hiddden" => "hidden",
	 "highlighlighted" => "highlighted",
	 "Higlighting" => "Highlighting",
	 "honour" => "honor",
	 "honouring" => "honoring",
	 "honours" => "honors",
	 "i'm" => "I'm",
	 "iconized" => "iconified",
	 "indentical" => "identical",
	 "immediatly" => "immediately",
	 "implemantation" => "implementation",
	 "implemenation" => "implementation",
	 "implimention" => "implementation",
	 "implmentation" => "implementation",
	 "imitatation" => "imitation",
	 "Incomming" => "Incoming",
	 "incomming" => "incoming",
	 "independend" => "independent",
	 "indice" => "index",
	 "indeces" => "indices",
	 "Inifity" => "Infinity",
	 "infomation" => "information",
	 "informatation" => "information",
	 "inital" => "initial",
         "initalized" => "initialized",
	 "initalization" => "initialization",
	 "initilization" => "initialization",
	 "intialisation" => "initialization",
	 "intialization" => "initialization",
	 "Initalize" => "Initialize",
	 "initalize" => "initialize",
	 "Initialyze" => "Initialize",
	 "Initilialyze" => "Initialize",
	 "Initilize" => "Initialize",
	 "initilize" => "initialize",
	 "intiailize" => "initialize",
	 "Intialize" => "Initialize",
	 "intialize" => "initialize",
	 "intializing" => "initializing",
	 "isntance" => "instance",
	 "intruction" => "instruction",
	 "inteface" => "interface",
	 "Iterface" => "Interface",
         "interisting", "interesting",
	 "interrrupt" => "interrupt",
	 "Interupt" => "Interrupt",
	 "intrrupt" => "interrupt",
	 "interrups" => "interrupts",
	 "intervall" => "interval",
         "introdutionary" => "introductionary",
	 "introdution" => "introduction",
	 "invarient" => "invariant",
	 "invokation" => "invocation",
	 "is'nt" => "isn't",
	 "issueing" => "issuing",
	 "itselfs" => "itself",
	 "judgement" => "judgment",
	 "Konquerer" => "Konqueror",
	 "klicking" => "clicking",
	 "labelling" => "labeling",
	 "lauching" => "launching",
	 "learnt" => "learned",
	 "Lenght" => "Length",
	 "Licens" => "License",
         "licence" => "license",
	 "Licence" => "License",
	 "Licenced" => "Licensed",
	 "litle" => "little",
	 "localisation" => "localization",
	 "losely" => "loosely",
	 "mailboxs" => "mailboxes",
	 "managment" => "management",
	 "manangement" => "management",
	 "manupulation" => "manipulation",
	 "mesages" => "messages",
	 "millimetres" => "millimeters",
	 "miscellaneaous" => "miscellaneous",
         "mispelled" => "misspelled",
	 "modelling" => "modeling",
	 "Modelling" => "Modeling",
	 "modifing" => "modifying",
	 "modul" => "module",
	 "mulitple" => "multiple",
	 "mistery" => "mystery",
         "neccesary" => "necessary",
	 "neccessary" => "necessary",
	 "necessery" => "necessary",
         "nessecarry" => "necessary",
	 "negativ" => "negative",
	 "negociated" => "negotiated",
	 "negociation" => "negotiation",
	 "neogtiation" => "negotiation",
	 "neighbours" => "neighbors",
	 "neighbourhood" => "neighborhood",
	 "Noone" => "No-one",
	 "nonexistant" => "nonexistent",
	 "noticable" => "noticeable",
	 "occured" => "occurred",
	 "occurance" => "occurrence",
	 "occurrance" => "occurrence",
	 "occurrances" => "occurrences",
	 "occurence" => "occurrence",
	 "occurences" => "occurrences",
	 "occurances" => "occurrences",
	 "occuring" => "occurring",
	 "organise" => "organize",
	 "organiser" => "organizer",
	 "organisation" => "organization",
	 "organisations" => "organizations",
	 "Organisation" => "Organization",
	 "organisational" => "organizational",
	 "orignal" => "original",
	 "Originaly" => "Originally",
         "opend" => "opened",
	 "ouput" => "output",
	 "otehr" => "other",
	 "outputing" => "outputting",
	 "overidden" => "overridden",
	 "overriden" => "overridden",
	 "paramter" => "parameter",
	 "paramaters" => "parameters",
	 "parametres" => "parameters",
	 "paramters" => "parameters",
	 "paticular" => "particular",
	 "particularily" => "particularly",
	 "Pendings" => "Pending",
	 "percetages" => "percentages",
	 "Perfomance" => "Performance",
	 "performace" => "performance",
	 "preformance" => "performance",
	 "Periferial" => "Peripheral",
	 "permissable" => "permissible",
	 "hysical" => "physical",
	 "phyiscal" => "physical",
         "politness" => "politeness",
         "posssibility" => "possibility",
         "posibility" => "possibility",
	 "potentally" => "potentially",
	 "preceeded" => "preceded",
	 "preceeding" => "preceding",
	 "preemphasised" => "preemphasized",
	 "Preemphasised" => "Preemphasized",
         "prefered" => "preferred",
	 "preferrable" = "preferable",
         "Prefered" => "Preferred",
	 "presense" => "presence",
	 "priviledge" => "privilege",
	 "priviliges" => "privileges",
         "probatility" => "probability",
	 "properies" => "properties",
	 "problmes" => "problems",
         "proceedure" => "procedure",
	 "programme" => "program",
	 "programm" => "program",
	 "prgramm" => "program",
	 "promiscous" => "promiscuous",
	 "promped" => "prompted",
	 "Propogate" => "Propagate",
	 "protoypes" => "prototypes",
	 "Psuedo" => "Pseudo",
	 "psuedo" => "pseudo",
         "purposees" => "purposes",
	 "queing" => "queuing",
	 "queueing" => "queuing",
	 "Queueing" => "Queuing",
	 "realise" => "realize",
	 "realy" => "really",
	 "reasonnable" => "reasonable",
	 "resonable" => "reasonable",
	 "recevie" => "receive",
	 "recevie" => "receive",
	 "reciever" => "receiver",
	 "Recieve" => "Receive",
	 "Recieves" => "Receives",
	 "recieve" => "receive",
         "recives" => "receives",
	 "recieves" => "receives",
	 "recieved" => "received",
	 "receving" => "receiving",
	 "recognise" => "recognize",
         "recomended" => "recommended",
         "recommanded" => "recommended",
         "recommand" => "recommend",
	 "refered" => "referred",
         "Refeshes" => "Refreshes",
	 "regarless" => "regardless",
	 "Regsiter" => "Register",
	 "Reigster" => "Register",
	 "registred" => "registered",
	 "registaration" => "registration",
         "reimplemenations" => "reimplementations",
         "Reimplemenations" => "Reimplementations",
	 "releated" => "related",
	 "relevent" => "relevant",
         "relocateable" => "relocatable",
	 "remaing" => "remaining",
	 "remeber" => "remember",
	 "remebers" => "remembers",
	 "renewd" => "renewed",
         "replys" => "replies",
	 "requeusts" => "requests",
	 "relection" => "reselection",
	 "reets" => "resets",
	 "resetted" => "reset",
	 "ressources" => "resources",
	 "responsability" => "responsibility",
	 "retreive" => "retrieve",
	 "retreived" => "retrieved",
	 "savely" => "safely",
	 "saftey" => "safety",
	 "selectde" => "selected",
         "seperator" => "separator",
	 "smaple" => "sample",
	 "scather" => "scatter",
	 "scenerio" => "scenario",
	 "sceptical" => "skeptical",
	 "Seperate" => "Separate",
	 "Shouldnt" => "Shouldn't",
	 "shouldnt" => "shouldn't",
	 "shorctuts" => "shortcuts",
	 "Similarily" => "Similarly",
         "Sombody" => "Somebody",
         "seperated" => "separated",
         "seperation" => "separation",
 	 "specialised" => "specialized",
	 "specfic" => "specific",
	 "specifc" => "specific",
	 "Specificiation" => "Specification",
	 "specifed" => "specified",
	 "speficied" => "specified",
	 "specifiy" => "specify",
	 "specifing" => "specifying",
	 "specifieing" => "specifying",
         "speling" => "spelling",
	 "statfull" => "stateful",
	 "straighforward" => "straightforward",
	 "streched" => "stretched",
	 "stuctures" => "structures",
         "subcribed" => "subscribed",
	 "succeded" => "succeeded",
	 "sucess" => "success",
	 "succesful" => "successful",
         "sucessfull" => "successful",
	 "successfull" => "successful",
	 "sucessfully" => "successfully",
	 "succesfully" => "successfully",
	 "sucessfuly" => "successfully",
	 "sufficent" => "sufficient",
	 "superflous" => "superfluous",
	 "supress" => "suppress",
	 "swaped" => "swapped",
	 "synchronyze" => "synchronize",
         "synchronise" => "synchronize",
         "syncrounous" => "syncronous",
	 "syncronizing" => "synchronizing",
	 "syncronous" => "synchronous",
	 "sytem" => "system",
	 "tecnology" => "technology",
	 "terminatin" => "terminating",
	 "thet" => "that",
	 "threshhold" => "threshold",
         "threshholds" => "thresholds",
	 "throught" => "through",
	 "throuth" => "through",
	 "timming" => "timing",
	 "transation" => "transaction",
	 "tranceiver" => "transceiver",
	 "trasfered" => "transferred",
	 "transfering" => "transferring",
	 "tranlation" => "translation",
	 "transmition" => "transmission",
	 "transmittion" => "transmission",
	 "transmiter" => "transmitter",
	 "transmiting" => "transmitting",
	 "travelling" => "traveling",
	 "tiggered" => "triggered",
	 "triggerred" => "triggered",
	 "triggerg" => "triggering",
	 "truely" => "truly",
         "trys" => "tries",
	 "uglyness" => "ugliness",
	 "unallowed" => "disallowed",
	 "uncrypted" => "unencrypted",
	 "Uncutt" => "Uncut",
	 "unneccessay" => "unnecessary",
	 "unneccessary" => "unnecessary",
	 "underrrun" => "underrun",
	 "underlieing" => "underlying",
	 "undestood" => "understood",
	 "undesireable" => "undesirable",
	 "Undexpected" => "Unexpected",
	 "Unfortunatly" => "Unfortunately",
	 "unfortunatly" => "unfortunately",
	 "unitialized" => "uninitialized",
         "unsuccesful" => "unsuccessful",
         "unusuable" => "unusable",
	 "unkown" => "unknown",
	 "usuable" => "usable",
	 "usally" => "usually",
	 "usuallly" => "usually",
	 "usefull" => "useful",
	 "verfication" => "verification",
	 "verically" => "vertically",
	 "verticies" => "vertices",
	 "versins" => "versions",
         "vicitim" => "victim",
	 "Volumen" => "Volume",
	 "waranty" => "warranty",
	 "watseful" => "wasteful",
	 "wheter" => "whether",
	 "whith" => "with",
         "wich" => "which",
	 "wierd" => "weird",
	 "wieving" => "wieving",
	 "willl" => "will",
	 "Writting" => "Writing",
	 "writting" => "writing",
         "yeld" => "yield",
	 "wich" => "which"
         );

sub spell_file($)
{
    my ($f) = @_;
    my $firsttime = 1;

    if(open(IN, "<$f")) {
        my @c = <IN>;

        my $matches = 0;
        foreach my $line (@c) {
            my @words = split /\W/, $line;
            foreach my $w (@words) {
                if(defined($fix{$w})) {
                    $matches++;
                    $line =~ s/\b$w\b/$fix{$w}/g;
                }
            }
            foreach my $w (keys %fix) {
                if ($line =~ /$w/ and $line !~ /$fix{$w}/) {
                    if ($firsttime) {
                        print "spelling $f\n";
                        $firsttime = 0;
                    }
                    print "nonword misspelling: $w\n";
                }
            }
        }
        close (IN);
        if($matches) {
            open (O, ">$f");
            print O @c;
            close(O);
        }
    }
}

my @dirqueue = ();

sub processDir($)
{
    my ($d) = @_;
    my $e;

    print "processDir: $d\n";

    opendir (DIR, "$d") || die "couldn't read dir: $d";
    while ($e = readdir(DIR)) {
        next if ($e eq ".");
        next if ($e eq "..");
        next if ($e eq "CVS");
        next if ($e =~ /\.desktop$/);
        next if ($e =~ /^\./);
        push (@dirqueue, "$d/$e") if (-d ("$d/$e"));
        next if (-d ("$d/$e"));

        my $type = `file $d/$e`;
        if ($type !~ /(text|ASCII)/i) {
            print "** Skipping $d/$e\n";
            next;
        }
        &spell_file("$d/$e") if (-f ("$d/$e"));
    }
    closedir(DIR);
}

push (@dirqueue, getcwd());

while($#dirqueue >= 0) {
    processDir( pop @dirqueue );
}

