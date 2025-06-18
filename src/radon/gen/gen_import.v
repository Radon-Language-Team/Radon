module gen

import structs

const core_import_string = '#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void println_str(char *x) 
{ 
	printf("%s\\n", x);
}
void println_int(int x)
{
  printf("%d\\n", x);
}

char *read(char *message) 
{
  char *buffer = malloc(1024);
  if (!buffer) return NULL;

  printf("%s ", message);
  if (fgets(buffer, 1024, stdin) == NULL) 
  {
    buffer[0] = \'\\0\';
    return buffer;
  }

  size_t len = strlen(buffer);
  if (len > 0 && buffer[len - 1] == \'\\n\')
    buffer[len - 1] = \'\\0\';

  return buffer;
}
'

fn gen_import(node structs.ImportStmt) string {
	if node.path.contains('.rad') {
		return gen_custom_import(node)
	} else {
		return gen_radon_import(node)
	}
}

fn gen_radon_import(node structs.ImportStmt) string {
	if node.path == 'core' {
		return core_import_string
	} else {
		return ''
	}
}

fn gen_custom_import(node structs.ImportStmt) string {
	println('[NOT YET GENERATED] Custom import -> ${node.path}')
	return ''
}
