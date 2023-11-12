//
//  ToastModel.swift
//  APNs Helper
//
//  Created by joker on 2023/5/18.
//

import AlertToast

class ToastModel {
    var mode: AlertToast.DisplayMode
    var type: AlertToast.AlertType
    var title: String?
    var subtitle: String?
    var style: AlertToast.AlertStyle?

    init(
        mode: AlertToast.DisplayMode,
        type: AlertToast.AlertType,
        title: String? = nil,
        subtitle: String? = nil,
        style: AlertToast.AlertStyle? = nil) {
            self.mode = mode
            self.type = type
            self.title = title
            self.subtitle = subtitle
            self.style = style
        }

    var shouldShow: Bool {
        var hasTitle = false
        var hasSubtitle = false
        if let title = title, !title.isEmpty {
            hasTitle = true
        }
        if let subtitle = subtitle, !subtitle.isEmpty {
            hasSubtitle = true
        }
        return hasTitle || hasSubtitle
    }

    func mode(_ mode: AlertToast.DisplayMode) -> Self {
        self.mode = mode
        return self
    }

    func type(_ type: AlertToast.AlertType) -> Self {
        self.type = type
        return self
    }

    func title(_ title: String) -> Self {
        self.title = title
        return self
    }

    func subtitle(_ subtitle: String) -> Self {
        self.subtitle = subtitle
        return self
    }

    func style(_ style: AlertToast.AlertStyle) -> Self {
        self.style = style
        return self
    }

}

extension ToastModel {
    static func info() -> ToastModel {
        return ToastModel(
            mode: .hud,
            type: .regular,
            style: .style(backgroundColor: .orange)
        )
    }

    static func success() -> ToastModel {
        return ToastModel(
            mode: .alert,
            type: .complete(.green)
        )
    }
}
