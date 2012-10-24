// Copyright (C) 2012 Eric Schulte                         -*- C++ -*-
#ifndef DRIVER_ASTMUTATORS_H
#define DRIVER_ASTMUTATORS_H

#include "clang/Basic/LLVM.h"
#include "clang/AST/ASTConsumer.h"
#include "clang/AST/ASTContext.h"

namespace clang {  

enum ACTION { NUMBER, IDS, ANNOTATOR, LISTER, DELETE, INSERT, SWAP, GET, SET };

ASTConsumer *CreateASTNumberer();
ASTConsumer *CreateASTIDS();
ASTConsumer *CreateASTAnnotator();
ASTConsumer *CreateASTLister();
ASTConsumer *CreateASTDeleter(unsigned int Stmt);
ASTConsumer *CreateASTInserter(unsigned int Stmt1, unsigned int Stmt2);
ASTConsumer *CreateASTSwapper(unsigned int Stmt1, unsigned int Stmt2);
ASTConsumer *CreateASTGetter(unsigned int Stmt);
ASTConsumer *CreateASTSetter(unsigned int Stmt, StringRef Value);

}

#endif
