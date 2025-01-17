/*
 * Copyright (c) 2022, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.graphql.compiler.schema.generator;

import io.ballerina.compiler.syntax.tree.ServiceDeclarationNode;
import io.ballerina.stdlib.graphql.compiler.schema.types.Schema;

import java.util.HashMap;
import java.util.Map;

/**
 * Stores the mapping between a Ballerina service and the generated GraphQL schema.
 */
public class GraphqlModifierContext {
    private final Map<ServiceDeclarationNode, Schema> nodeSchemaMap;

    public GraphqlModifierContext() {
        this.nodeSchemaMap = new HashMap<>();
    }

    public void add(ServiceDeclarationNode node, Schema schema) {
        this.nodeSchemaMap.put(node, schema);
    }

    public Map<ServiceDeclarationNode, Schema> getNodeSchemaMap() {
        return this.nodeSchemaMap;
    }
}
