:- module(run_bioned,
	  [ run_bioned/0,
	    delete_bioned/0,
	    make_rand_uri/2,
	    make_rand_uri/3
	  ]).

user:file_search_path(data,       data).

:- use_module(library(semweb/rdf_db)).

:- rdf_register_ns(bgn,    'http://data.biographynet.nl/rdf/').
:- rdf_register_ns(edm,    'http://www.europeana.eu/schemas/edm/').
:- rdf_register_ns(ore,    'http://www.openarchives.org/ore/terms/').
:- rdf_register_ns(prov,   'http://www.w3.org/ns/prov#').
:- rdf_register_ns(pplan,  'http://purl.org/net/p-plan#').
:- rdf_register_ns(bioc,  'http://www.ldf.fi/schema/bioc/').
:- rdf_register_ns(crm, 'http://www.cidoc-crm.org/cidoc-crm/') .
:- rdf_register_ns(idm, 'https://intavia.org/idm/').

:- use_module([ library(xmlrdf/xmlrdf),
		library(semweb/rdf_cache),
		library(semweb/rdf_library),
		library(semweb/rdf_turtle_write)
	      ]).
:- use_module(rewrite_bioned).

load_ontologies :-
	rdf_load_library(dc),
	rdf_load_library(skos),
	rdf_load_library(rdfs),
     /*   rdf_load('prov-o.ttl'),    */
	rdf_load_library(owl).

:- initialization			% run *after* loading this file
	rdf_set_cache_options([ global_directory('cache/rdf'),
				create_global_directory(true)
			      ]),
	load_ontologies.

load_biodes_file(XmlFile):-
        absolute_file_name(XmlFile, File,
			   [ access(read)
			   ]),
	load(File).
/*
	extractFileInfo(XmlFile, FileID, PersID, Suffix),
	setup_call_cleanup(
	    b_setval(bgn_context, bionedfileinfo(FileID, PersID, Suffix)),
	    rewrite(addidsandlinktoperson),
	    b_setval(bgn_context, [])
	).
*/

load_xml_dir:-
	expand_file_name('data/xml/full_preprocessed/*.xml', X),
%	expand_file_name('data/xml/full_preprocessed/*.XML', Y),
%	append(X, Y, Z),
	maplist(load_biodes_file, X).



load(File) :-
	rdf_current_ns(bgn, Prefix),
	load_xml_as_rdf(File,
			[ dialect(xml), % this is dialect, others are xmlns
			  unit(bioport), % the root unit
			  prefix(Prefix), % prefix to use
			  graph(bioned) % save as graph name
			]).

% extractFileInfo(File, FileID, PersID, Suffix) :-
%	atomic_list_concat([_Path, FileName], 'data/xml/full/', File),
%	atomic_list_concat([FileID, _Extention], '.', FileName),
%	atomic_list_concat([PersID, Suffix], '_', FileID).



run_bioned:-
	load_xml_dir,

/*
        load_biodes_file('00376149_13.xml'),
*/
	rewrite,
	save_bioned.


save_bioned:-
	absolute_file_name(data('rdf/biographynet.ttl'), File,
			   [ access(write)
			   ]),
	rdf_save_turtle(File,[graph(bioned)]).




delete_bioned:-
	rdf_retractall(_,_,_,bioned).


% UTILITY
%
make_rand_uri(InputURI,OutputURI):-
	random(1,9999999,Rand),
	atomic_list_concat([InputURI,Rand],OutputURI).
make_rand_uri(InputURI,List,OutputURI):-
	random(1,9999999,Rand),
	atomic_list_concat([InputURI,Rand|List],OutputURI).
