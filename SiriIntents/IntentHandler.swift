//
//  IntentHandler.swift
//  SiriIntents
//
//  Created by Xavi Aracil on 30/4/22.
//

import Intents

class IntentHandler: INExtension {

    override func handler(for intent: INIntent) -> Any? {
        if intent is AddProductIntent {
            return AddProductHandler()
        }

        if intent is INAddTasksIntent {
            return AddProductStandardHandler()
        }

        fatalError("Intent not suported")
    }

}
