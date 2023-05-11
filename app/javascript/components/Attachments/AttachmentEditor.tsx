import React, { ChangeEvent, useState } from "react";
import copyToClipboard, { copySupported } from "../../lib/copyToClipboard";
import useModalStore from "../../stores/useModalStore";
import useToastStore from "../../stores/useToastStore";
import { AttachmentResource, Locale } from "../../types";
import { putJson } from "../../lib/request";

interface AttachmentEditorProps {
  attachment: AttachmentResource;
  locale: string;
  locales: { [index: string]: Locale };
  onUpdate: (localizations: Record<string, Record<string, string>>) => void;
}

export default function AttachmentEditor(props: AttachmentEditorProps) {
  const { attachment, locales } = props;

  const [locale, setLocale] = useState(props.locale);
  const [localizations, setLocalizations] = useState({
    name: attachment.name || {},
    description: attachment.description || {}
  });

  const notice = useToastStore((state) => state.notice);
  const closeModal = useModalStore((state) => state.close);

  const updateLocalization =
    (name: "name" | "description") => (evt: ChangeEvent<HTMLInputElement>) => {
      setLocalizations({
        ...localizations,
        [name]: { ...localizations[name], [locale]: evt.target.value }
      });
    };

  const copyEmbedCode = (evt: Event) => {
    evt.preventDefault();
    copyToClipboard(`[attachment:${attachment.id}]`);
    notice("Embed code copied to clipboard");
  };

  const save = (evt: Event) => {
    evt.preventDefault();
    evt.stopPropagation();

    const data = { ...localizations };

    void putJson(`/admin/attachments/${attachment.id}`, { attachment: data });

    if (props.onUpdate) {
      props.onUpdate(data);
    }
    closeModal();
  };

  const inputDir = (locales && locales[locale] && locales[locale].dir) || "ltr";

  return (
    <div className="attachment-editor">
      <form>
        {props.locales && Object.keys(locales).length > 1 && (
          <div className="field">
            <label>Locale</label>
            <select
              name="locale"
              value={locale}
              onChange={(e) => setLocale(e.target.value)}>
              {Object.keys(locales).map((key) => (
                <option key={`locale-${key}`} value={key}>
                  {locales[key].name}
                </option>
              ))}
            </select>
          </div>
        )}
        <div className="field">
          <label>Name</label>
          <input
            type="text"
            className="name"
            lang={locale}
            dir={inputDir}
            value={localizations.name[locale] || ""}
            onChange={updateLocalization("name")}
          />
        </div>
        <div className="field">
          <label>Description</label>
          <textarea
            className="description"
            value={localizations.description[locale] || ""}
            lang={locale}
            dir={inputDir}
            onChange={updateLocalization("description")}
          />
        </div>
        <div className="field embed-code">
          <label>Embed code</label>
          <input
            type="text"
            value={`[attachment:${attachment.id}]`}
            disabled={true}
          />
          {copySupported() && <button onClick={copyEmbedCode}>Copy</button>}
        </div>
        <div className="field">
          <label>File</label>
          <a href={attachment.url} rel="noreferrer" target="_blank">
            {attachment.filename}
          </a>
        </div>
        <div className="buttons">
          <button onClick={save}>Save</button>
          <button onClick={closeModal}>Cancel</button>
        </div>
      </form>
    </div>
  );
}
