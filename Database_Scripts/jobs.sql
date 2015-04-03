CREATE INDEX pfname_index ON persons(first_name) INDEXTYPE IS CTXSYS.CONTEXT;
CREATE INDEX plname_index ON persons(last_name) INDEXTYPE IS CTXSYS.CONTEXT;
CREATE INDEX diag_index ON radiology_record(diagnosis) INDEXTYPE IS CTXSYS.CONTEXT;
CREATE INDEX descr_index ON radiology_record(description) INDEXTYPE IS CTXSYS.CONTEXT;


@drjobdml pfname_index 1
@drjobdml plname_index 1
@drjobdml diag_index 1
@drjobdml descr_index 1
