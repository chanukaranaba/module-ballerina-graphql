// Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import graphql.parser;

class ExecutorVisitor {
    *parser:Visitor;

    private final __Schema schema;
    private final Engine engine; // This field needed to be accessed from the native code
    private Data data;
    private ErrorDetail[] errors;
    private Context context;
    private map<Upload|Upload[]> fileInfo;
    private any result;

    isolated function init(Engine engine, __Schema schema, Context context, map<Upload|Upload[]> fileInfo,
        any result = ()) {

        self.engine = engine;
        self.schema = schema;
        self.context = context;
        self.fileInfo = fileInfo;
        self.data = {};
        self.result = result;
        self.errors = [];
    }

    public isolated function visitDocument(parser:DocumentNode documentNode, anydata data = ()) {}

    public isolated function visitOperation(parser:OperationNode operationNode, anydata data = ()) {
        foreach parser:SelectionNode selection in operationNode.getSelections() {
            selection.accept(self, operationNode.getKind());
        }
    }

    public isolated function visitField(parser:FieldNode fieldNode, anydata data = ()) {
        parser:RootOperationType operationType = <parser:RootOperationType>data;
        if fieldNode.getName() == SCHEMA_FIELD {
            IntrospectionExecutor introspectionExecutor = new(self.schema);
            self.data[fieldNode.getAlias()] = introspectionExecutor.getSchemaIntrospection(fieldNode);
        } else if fieldNode.getName() == TYPE_FIELD {
            IntrospectionExecutor introspectionExecutor = new(self.schema);
            self.data[fieldNode.getAlias()] = introspectionExecutor.getTypeIntrospection(fieldNode);
        } else {
            if operationType == parser:OPERATION_QUERY {
                executeQuery(self, fieldNode);
            } else if operationType == parser:OPERATION_MUTATION {
                executeMutation(self, fieldNode);
            } else if operationType == parser:OPERATION_SUBSCRIPTION {
                executeSubscription(self, fieldNode, self.result);
            }
        }
    }

    public isolated function visitArgument(parser:ArgumentNode argumentNode, anydata data = ()) {}

    public isolated function visitFragment(parser:FragmentNode fragmentNode, anydata data = ()) {
        foreach parser:SelectionNode selection in fragmentNode.getSelections() {
            selection.accept(self, data);
        }
    }

    public isolated function visitDirective(parser:DirectiveNode directiveNode, anydata data = ()) {}

    public isolated function visitVariable(parser:VariableNode variableNode, anydata data = ()) {}

    isolated function getOutput() returns OutputObject {
        return getOutputObject(self.data, self.errors);
    }
}
